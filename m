From: Dave Taht <dave.taht@gmail.com>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Fri, 23 Dec 2011 18:54:01 +0100
Message-ID: <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	<20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	<1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60470 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224Ab1LWRyC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 12:54:02 -0500
Received: by iaeh11 with SMTP id h11so15404118iae.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 09:54:01 -0800 (PST)
In-Reply-To: <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 23, 2011 at 6:39 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 23 d=E9cembre 2011 =E0 18:33 +0100, Eric Dumazet a =E9cri=
t :
>> Le dimanche 18 d=E9cembre 2011 =E0 11:55 -0800, Stephen Hemminger a =
=E9crit :
>> > On Sun, 18 Dec 2011 00:12:12 -0500
>> > "John A. Sullivan III" <jsullivan@opensourcedevel.com> wrote:
>> >
>> > > Since netem appears to be classless, we realized we would need t=
o
>> > > replace the SFQ on each leaf with netem which we really didn't w=
ant to
>> > > do - not only to not lose SFQ but because we didn't want to main=
tain the
>> > > netem parameters on each leaf. =A0So, we activated our ifb1 inte=
rface,
>> > > placed netem on it and redirected all the egress traffic to ifb1=
=2E =A0Taht
>> > > worked fine.
>> >
>> > Current versions of netem can take one class.
>> > --
>>
>> Hmm, I can see that (commit 10f6dfcfde884441)
>>
>> But it wont work very well, it assumes qdisc uses a single queue if
>> netem reordering is requested :
>>
>> (__skb_queue_head(&q->qdisc->q, skb))
>>
>> We should allow reordering if netem queue is changed from tfifo, onl=
y if
>> new qdisc is compatible with __skb_queue_head(&q->qdisc->q, skb)
>>
>> (maybe providing a new ->queue_at_head() new ops)
>
> Also, child qdisc must not scratch skb->cb[], since netem stores
> time_to_send in it.

Are there any place where all 48 bytes of cb are used?

I wouldn't mind if 'time_to_send' became a separate skb field
for a more generic 'time_in_queue'...

> I guess nobody actually tried this netem mis-feature :(


>
> I'll send a fix.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
