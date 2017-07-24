From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v11 1/4] net netlink: Add new type
 NLA_BITFIELD_32
Date: Mon, 24 Jul 2017 13:18:06 +0200
Message-ID: <20170724111806.GB1868@nanopsycho>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33651 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751649AbdGXLSI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 07:18:08 -0400
Received: by mail-wr0-f194.google.com with SMTP id y43so17180322wrd.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 04:18:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 24, 2017 at 03:35:43AM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>Generic bitflags attribute content sent to the kernel by user.
>With this type the user can either set or unset a flag in the
>kernel.
>
>The nla_value is a bitmap that defines the values being set
>The nla_selector is a bitmask that defines which value is legit.
>
>A check is made to ensure the rules that a kernel subsystem always
>conforms to bitflags the kernel already knows about. i.e
>if the user tries to set a bit flag that is not understood then
>the _it will be rejected_.
>
>In the most basic form, the user specifies the attribute policy as:
>[ATTR_GOO] = { .type = NLA_BITFIELD_32, .validation_data = &myvalidflags },
>
>where myvalidflags is the bit mask of the flags the kernel understands.
>
>If the user _does not_ provide myvalidflags then the attribute will
>also be rejected.
>
>Examples:
>nla_value = 0x0, and nla_selector = 0x1
>implies we are selecting bit 1 and we want to set its value to 0.
>
>nla_value = 0x2, and nla_selector = 0x2
>implies we are selecting bit 2 and we want to set its value to 1.

Oh, 2 more things:

[...]


>@@ -46,6 +60,13 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
> 			return -ERANGE;
> 		break;
> 
>+	case NLA_BITFIELD_32:

Now that I'm looking at it, perhaps just "NLA_BITFIELD32" looks nicer
and aligns with "NLA_U32" and others.



>+		if (attrlen != sizeof(struct nla_bitfield_32))
>+			return -ERANGE;
>+
>+		return validate_nla_bitfield_32(nla, pt->validation_data);
>+		break;

Remove the pointless "break" from here.
