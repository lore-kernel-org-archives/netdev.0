From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check
Date: Sat, 11 Jun 2011 08:05:37 +0800
Message-ID: <BANLkTi=LeDecHK4x+6qa-q2h5Duub4zoTg@mail.gmail.com>
References: <m11uzcidvq.fsf_-_@fess.ebiederm.org> <BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
 <BANLkTikM1TuO_S9LuJv30uV9oGgLjE09Xw@mail.gmail.com> <20110605.141446.1838641439880246155.davem@davemloft.net>
 <20110610083539.GB17568@minipsycho.redhat.com> <BANLkTinqikKoeW6mbjMV9nPii0Nzp4vSdQ@mail.gmail.com>
 <20110610093413.GC17568@minipsycho.redhat.com> <BANLkTimHi7V3YwbPepLyW7=pTS7hQVxEBQ@mail.gmail.com>
 <20110610103503.GD17568@minipsycho.redhat.com> <BANLkTinctdoyYJo+sU9qUWV8uZV8yGNdnw@mail.gmail.com>
 <20110610165656.GA25677@minipsycho.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, pratnakarlx@gmail.com,
	ebiederm@xmission.com, shemminger@linux-foundation.org,
	greearb@candelatech.com, nicolas.2p.debian@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55367 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758305Ab1FKAF6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 20:05:58 -0400
Received: by bwz15 with SMTP id 15so2570784bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 17:05:57 -0700 (PDT)
In-Reply-To: <20110610165656.GA25677@minipsycho.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2011 at 12:56 AM, Jiri Pirko <jpirko@redhat.com> wrote:
> This time heavily based on Eric's V2. mac_len is reset at appropriate
> places. Also skb->data is adjusted to point to beginning of mac heade=
r
> before calling vlan_insert_tag.
>
> Please review (fingers crossed).
>
> Subject: [patch net-2.6 v2.1] vlan: Fix the ingress VLAN_FLAG_REORDER=
_HDR check
>
> Testing of VLAN_FLAG_REORDER_HDR does not belong in vlan_untag
> but rather in vlan_do_receive. =A0Otherwise the vlan header
> will not be properly put on the packet in the case of
> vlan header accelleration.
>
> As we remove the check from vlan_check_reorder_header
> rename it vlan_reorder_header to keep the naming clean.
>
> Fix up the skb->pkt_type early so we don't look at the packet
> after adding the vlan tag, which guarantees we don't goof
> and look at the wrong field.
>
> Use a simple if statement instead of a complicated switch
> statement to decided that we need to increment rx_stats
> for a multicast packet.
>
> Hopefully at somepoint we will just declare the case where
> VLAN_FLAG_REORDER_HDR is cleared as unsupported and remove
> the code. =A0Until then this keeps it working correctly.
>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Acked-by: Changli Gao <xiaosuo@gmail.com>

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
