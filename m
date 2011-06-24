From: Janardhan Iyengar <jana.iyengar@gmail.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Fri, 24 Jun 2011 10:58:17 -0400
Message-ID: <4E04A609.7010206@fandm.edu>
References: <4DE44218.4070306@krellan.com>	 <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>	 <4DE5F3E3.2080609@krellan.com> <1306949723.8149.2202.camel@tardy>
Reply-To: janardhan.iyengar@fandm.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Lehan <linux@krellan.com>, Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>, Bryan Ford <bryan.ford@yale.edu>
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:64480 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab1FXO6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 10:58:22 -0400
Received: by qwk3 with SMTP id 3so1371526qwk.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 07:58:21 -0700 (PDT)
In-Reply-To: <1306949723.8149.2202.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Reviving this thread... apologies for dropping it.]

Rick,

Thanks for your note.  I agree that it does seem like we're simply addi=
ng to the metaphorical pile.  And my first knee-jerk response would be =
that there's not much else one can do in the modern IPv4 Internet :-)

That said, I'd like to point out that when you say that problems at lay=
er 4 need to be fixed, there are two kinds of changes that can be consi=
dered -- the layer 4 protocol, and the API it offers to apps.  Changes =
to the API, which is what we're proposing, is not a modification to the=
 transport layer protocol per se.  In other words, we are changing the =
service that TCP offers to apps, and not the protocol.

The non-portability that you point out in the second part of your note,=
 while a completely legitimate point, is again an API issue.  While thi=
s API is non-portable because it doesn't exist in other OSes yet, that =
is a matter of time (hopefully), and we're hoping to start the process =
with Linux.  And, it is easy enough for an app to fail over to using si=
mple TCP behavior where the sockopt is not supported.

You also point out that we could perhaps fix the shortcomings of TCP by=
 actively building and deploying alternative transports -- we've tried =
that and failed exactly because we've missed the point that the narrow =
waist of the Internet hourglass is no longer just IP, but includes TCP =
and UDP as well (and sometimes just TCP.)  For the entire time I've bee=
n working with SCTP (since 2001), we've been working on and trying to g=
et SCTP through middleboxes, but as it stands, we still only have pocke=
ts of success.  Try using SCTP in the wild; your packets are quite like=
ly to get black-holed within your home/ISP network.  The problem with m=
iddleboxes is that the IETF missed the boat on providing standards for =
these devices, and there are very few (if any) points of pressure that =
can be applied to change these devices in the network.  As a result, ge=
tting any new non-network-compatible transport deployed over the networ=
k remains untenable.

Our goal is to be able to provide new network services while remaining =
compatible with the network.  As we see it, that is the only option tha=
t remains if we are to consider any new transport services beyond TCP's=
 straitjacketed one.  As it turns out, our work shows that we _can_ off=
er more services using the same TCP protocol, which is a win-win, since=
 the new services remain network-compatible.

Note:  I'm talking largely about the v4 Internet.  The v6 Internet will=
 hopefully have fewer devices that interpose on the transport layer, es=
p. NAPTs;  however, I expect fully that firewalls and PEPs will still u=
se transport layer information, requiring them to be able to read/under=
stand transport header information.

- jana

On 6/1/11 1:35 PM, Rick Jones wrote:
> On Wed, 2011-06-01 at 01:10 -0700, Josh Lehan wrote:
>> On 05/31/2011 10:23 AM, Yuchung Cheng wrote:
>>> This paper may have a solution to your problem
>>> "Minion=E2=80=94an All-Terrain Packet Packhorse to Jump-Start Stall=
ed Internet
>>> Transports"
>>> http://csweb1.fandm.edu/jiyengar/lair/papers/minion-pfldnet2010.pdf
>>
>> Nice, thanks for pointing me to this.  I appreciate the helpful answ=
er,
>> instead of just saying "use UDP" or "use SCTP".  That's not the poin=
t.
>>
>> For better or for worse, TCP is realistically the only viable protoc=
ol
>> for streaming to the largest possible audience these days, hence my
>> question about adding this feature to the Linux TCP implementation.
>
> Isn't that treating the symptoms of problems at layers 8 and 9 (*) wi=
th
> kludges (perhaps hacks if one is feeling charitable) at the user
> interface to layer 4?  Just how many more little bits can we add to t=
he
> great pile before the aroma is overpowering?  Or to abuse another
> metaphor, is there really any camel's back left here?
>
> And while Linux has had some slightly non-trivial, non-portable
> enhancements to its interface to a TCP endpoint (TCP_CORK is somethin=
g
> that comes to mind) I don't think any of them have been anywhere near=
ly
> as large a change to a fundamental semantic of a TCP connection as wh=
at
> you propose.
>
> rick jones
>
> *
> http://www.isc.org/store/logoware-clothing/isc-9-layer-osi-model-cott=
on-t-shirt
>
>

--=20
Janardhan Iyengar
Assistant Professor, Computer Science
=46ranklin & Marshall College
http://www.fandm.edu/jiyengar
