From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Wed, 7 Dec 2011 14:27:57 +0100
Message-ID: <CAA93jw58s4DG7Ow+j-cCgtD4UsWRUPZ-pbmeF1J1cZcaxCDRsw@mail.gmail.com>
References: <9bf91034-a860-4144-858b-c9000964ea1d@jasiiieee>
	<1323263079.2312.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44163 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755693Ab1LGN16 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 08:27:58 -0500
Received: by iakc1 with SMTP id c1so935255iak.19
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2011 05:27:58 -0800 (PST)
In-Reply-To: <1323263079.2312.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2011 at 2:04 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 06 d=E9cembre 2011 =E0 14:44 -0500, John A. Sullivan III a =E9=
crit :
>> Interesting. =A0Would that still be true if all the traffic is the s=
ame,
>> i.e., nothing but iSCSI packets on the network? Or would just dumpin=
g
>> packets with minimal processing be fastest? Thanks - John
>
> Dave focuses on fairness and latencies under ~20 ms (a typical (under=
)
> provisioned ADSL (up)link shared by many (hostile) flows, with variou=
s
> type of services)

True, that is my focus, but queuing theory applies at all time scales.

If it didn't, the universe, and not just the internet, would have melte=
d
down long ago.

And I did ask specifically what sort of latencies he was trying to addr=
ess.

If he's hovering at close to line rate (wow), and yet experiencing
serious delays on short traffic, perhaps what I describe below may appl=
y.

> I doubt this is your concern ? You want high throughput more than low
> latencies ...

My assumption  - is that your 'iSCSI' packets are TCP streams. If they =
aren't,
then some of what I say below does not apply, although I tend to be
a believer in FQ technologies for their effects on downstream buffering=
=2E

I freely confess to not grokking how iSCSI is deployed. My understandin=
g
is that TCP is used to negotiate a virtual connection between two endpo=
ints,
and there are usually very few - usually one - endpoints.

1) TCP grabs all the bandwidth it can. If you have no packet loss,
it will eat more bandwidth, as rapidly as it can ramp up. Until it even=
tually
has packet loss.

Q) John indicated he didn't want any packet loss, so I for starters que=
stioned
my assumption he was using tcp, and secondly it was late, and I was
feeling snarky.  I honestly should stay in the .2ms to 10000ms range I'=
m
comfortable in.

2) Once you have one stream so completely dominating a connection
it can starve other stream's attempts to ramp up.

> Your workload is probably under _one_ ms latencies, and dedicated lin=
k
> to address few targets.

That was my second question, basically, how many links are in use?

More than 1 introduces a head of line problem between flows.

> If you have to use a Qdisc (and expensive packet classification), the=
n
> something is wrong in your iSCSI network connectivity :)
>
> Please note that with BQL, the NIC TX ring size doesn=92t matter, and=
 you
> could get "Virtual device ethX asks to queue packet!" warnings in you=
r
> message log.

so his tx 4000 is 'about right', even without BQL?

>
> So before removing Qdisc, you also want to make sure BQL is disabled =
for
> your NIC device/queues.
> (BQL is scheduled for linux-3.3)
>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
