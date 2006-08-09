From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: Re: 3945 driver using d80211
Date: Wed, 09 Aug 2006 14:07:36 -0700
Message-ID: <44DA4E98.1010002@linux.intel.com>
References: <44D901C9.6090304@linux.intel.com>	 <200608081440.48623.flamingice@sourmilk.net>	 <44D99558.1000507@sipsolutions.net>	 <200608090947.20291.flamingice@sourmilk.net> <1155151351.5788.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Wu <flamingice@sourmilk.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:51995 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751147AbWHIVHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 17:07:41 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1155151351.5788.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46or 3945 a lot of functionalities were moved to the driver level, wha=
t=20
kept in the firmware is basically some timely related functions like=20
beacon in IBSS mode but the beacon frame is provided by the driver and=20
the firmware is responsible to send it according to the timing=20
constrains. Also scanning was left in the firmware. We don=92t do and=20
authentication or association frame in the firmware and we use d80211 t=
o=20
do this. We just needed to know once we associated to inform the=20
firmware we are associated now. I just want to say d80211 was very=20
flexible and easy to work with, the porting process was smooth and we=20
only faces these problems with a working workaround and I thought we ca=
n=20
even make d80211 more flexible to cater more varieties of cards. For=20
ipw2[2/1]00 we did a gap analysis and we found it is hard to port it to=
=20
use d80211 because of what mentioned below. I hope to post 3945 with=20
d80211 code sometime next week so we can have the code available for ou=
r=20
discussion.


Thanks
Mohamed

Dan Williams wrote:

>On Wed, 2006-08-09 at 09:47 -0700, Michael Wu wrote:
> =20
>
>>On Wednesday 09 August 2006 00:57, Johannes Berg wrote:
>>   =20
>>
>>>Please not, for now. We need someone pushing for fullmac features in
>>>d80211, we need those anyway for embedded systems that can't afford
>>>running all of it on the main CPU. While obviously Intel would benef=
it
>>>from doing this since a lot more d80211 features would come availabl=
e,
>>>the greater good would be having a main-stream card that someone car=
es
>>>about and helps making d80211 full-mac capable.
>>>
>>>     =20
>>>
>>It's not that hard to generate probe, authentication, and association=
 frames,=20
>>and it isn't done frequently enough to stress any embedded system tha=
t can=20
>>run linux. Doing this would let 3945 take advantage of all the d80211=
=20
>>features, so why not?
>>
>>What level of fullmac support are we talking about? True fullmac card=
s (as I=20
>>define them) do not need to use d80211. WE19 is all they need, to add=
=20
>>WPA/WPA2 support. The IPW cards have a particularly unique split betw=
een=20
>>firmware and host 802.11 duties which I haven't seen in any other car=
ds. They=20
>>aren't quite fullmac enough to interface with WE directly, yet they o=
nly need=20
>>probe response handling to complete the picture. What other half-full=
mac,=20
>>half-softmac card besides the other IPW cards splits card/host 802.11=
 duties=20
>>along those lines? What other splits between card and host are out th=
ere? I=20
>>would be very reluctant to make changes to the 802.11 stack to suppor=
t=20
>>"fullmac" without evidence that other drivers need the change.
>>   =20
>>
>
>The atmel driver is somewhat of a hybrid.  For fullmac cards like airo=
,
>you just set the connection info up, let the card go, and you get back=
 a
>link event.  But the atmel driver controls authentication and
>association stuff; that's not done in firmware.  Look at:
>
>send_authentication_request()
>send_association_request()
>atmel_transmit_management_frame()
>atmel_management_frame()
>authenticate()
>associate()
>
>The driver has an auth/assoc state machine, receives management frames=
,
>and sends out the next appropriate management frame based on the curre=
nt
>state.  I think this is the reverse of ipw2100, where the firmware
>handles assoc/auth but not much else, but it's still less fullmac than
>airo, and more fullmac than softmac.
>
>Dan
>
>
>-
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> =20
>
