From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/5] vxlan: Group Policy extension
Date: Wed, 14 Jan 2015 17:08:21 -0800
Message-ID: <CA+mtBx9=coY1YwPn2ds66PD-J7FDaN_3Yf-_nB_vUEeZEDyJdg@mail.gmail.com>
References: <cover.1421280226.git.tgraf@suug.ch>
	<c73939bbb55a8e450de7931d830e0467a8340665.1421280226.git.tgraf@suug.ch>
	<CA+mtBx-CH2=D-wKmkjVTvhQOWhbf73NxcGrXrXOPE-E2PzJajQ@mail.gmail.com>
	<20150115002323.GH2105@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.ne>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36820 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231AbbAOBIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 20:08:21 -0500
Received: by mail-ig0-f178.google.com with SMTP id b16so12068150igk.5
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 17:08:21 -0800 (PST)
In-Reply-To: <20150115002323.GH2105@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 4:23 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/14/15 at 04:18pm, Tom Herbert wrote:
>> > diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> > index 99df0d7..06f7196 100644
>> > --- a/drivers/net/vxlan.c
>> > +++ b/drivers/net/vxlan.c
>> > @@ -126,6 +126,7 @@ struct vxlan_dev {
>> >         __u8              tos;          /* TOS override */
>> >         __u8              ttl;
>> >         u32               flags;        /* VXLAN_F_* in vxlan.h */
>> > +       u32               exts;         /* Enabled extensions */
>> >
>>
>> Thomas, why not just make a VXAM_F_GPB flag? Then this setting can be
>> saved in the flags for vxlan_dev and vxlan_sock so no exts field.
>
> Because we need to compare enabled extensions in vxlan_find_sock() to
> make sure we are not sharing a VXLAN socket with extensions enabled
> with a user which does not have the same extensions enabled.
>
> However, we do not want vxlan_find_sock() to compare all flags.
>
> So we need a bitmap that is ignored during the share check (flags) and
> a bitmap that must match to allow sharing (exts).
>
> The RCO extension is currently suffering from this bug which is causing
> a compatibility issue. I explained in the thread of your patch. I was
> under the imrpession that you would either send a v2 or fix it in a
> follow-up.

As I mentioned, we would also need to match receive checksum settings
which is not appropriately called an extension. A mask of interesting
flags could be used to do the comparison in vxlan_find_sock.
