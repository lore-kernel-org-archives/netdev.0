From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH 3/3 v2] netxen: qlogic ethernet : Fix endian bug.
Date: Mon, 12 Mar 2012 14:45:38 +0530
Message-ID: <CAOD=uF4qUhKRpWerFkouqNgzTNRL7DRu3G0kxgTb2E31Ox-=aA@mail.gmail.com>
References: <1331534303-4093-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120311.234808.1919218898572322534.davem@davemloft.net>
	<CAOD=uF6=2b-s_ErZ8zB+Mmo=gzE8wJdQ+h=TPz7U-sc1ucyw=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOD=uF6=2b-s_ErZ8zB+Mmo=gzE8wJdQ+h=TPz7U-sc1ucyw=Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject and comments are provided below for review.
This is for review not a formal one. Please let me know
if any more changes are required so that I can include it in
a formal patch.

-----------------------------------------------------------------------=
---------------------------------

Subject: [PATCH 3/3 v2] netxen: qlogic ethernet : Fix endian bug.

Change the datatype of "ip_addr" to __be32 as 'ip' should be in
big endian format.

Adapter needs "ip address" in big endian format stored at lower 32bit
of req.word[1]. netxen_config_ipaddr() now receives 'ip' in big endian
format. To satisfy adapter's need, use memcpy() to copy byte by byte
of 'ip' into lower 32bit of req.word[1].

Mac address and serial number of adapter need to be in little endian fo=
rmat.
Change the data type of the related  variables to __le32 / __le64 or ca=
st it
explicitly to __le32 / __le64 depending upon the requirement.

-----------------------------------------------------------------------=
----------------------------------------


Regards
Santosh



On Mon, Mar 12, 2012 at 12:22 PM, santosh prasad nayak
<santoshprasadnayak@gmail.com> wrote:
> Sure David.
> I will resend it with proper comment.
>
> Regards
> Santosh
>
> On Mon, Mar 12, 2012 at 12:18 PM, David Miller <davem@davemloft.net> =
wrote:
>> From: santosh nayak <santoshprasadnayak@gmail.com>
>> Date: Mon, 12 Mar 2012 12:08:23 +0530
>>
>>> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>>>
>>> Fix endian bug.
>>>
>>> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
>>
>> This is a very non-trivial patch, therefore the terse commit
>> message and the lack of any comments in this code is unacceptable.
>>
>> This commit message is not only terse, it's wrong. =A0You're not
>> fixing an endian bug, you're fixing several of them.
>>
>> Explain everything in your commit message.
>>
>>> =A0 =A0 =A0 req.words[0] =3D cpu_to_le64(cmd);
>>> - =A0 =A0 req.words[1] =3D cpu_to_le64(ip);
>>> + =A0 =A0 memcpy(&req.words[1], &ip, sizeof(u32));
>>
>> Nobody is going to read that and have any idea why it's correct unle=
ss
>> they happen to be able to discover the long thread you guys had this
>> past week working out how to do this change correctly.
>>
>> Putting a comment here for the rest of us mere mortals is therefore
>> absolutely required.
