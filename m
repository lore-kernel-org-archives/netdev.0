From: sridhar basam <sri@basam.org>
Subject: Re: [RFC PATCH 0/6] Understanding delays due to throttling under very
 heavy write load
Date: Fri, 10 Feb 2012 19:05:49 -0500
Message-ID: <CAGnVnB=scn13bE-+0xn4cqYnStObN+VvSMv4bL3whvRzXv1dFw@mail.gmail.com>
References: <1328111668-10068-1-git-send-email-jaschut@sandia.gov>
	<CAF3hT9BNc4n4HBNEqsf+d6-Rjv7TC8nJ1VponJCBVpLB8=_F5Q@mail.gmail.com>
	<4F2ADEAE.8010403@sandia.gov>
	<CAF3hT9CFkxnWR4zoTRPtyGU5CbfV_PvL+=dqnvZcr7G0HBOb+w@mail.gmail.com>
	<4F2AF085.6000405@sandia.gov>
	<CAF3hT9AcxxNtscFczP8fShSsaBm_4zhLQZ2F5c7h1YswVaXHkA@mail.gmail.com>
	<4F2C08A7.2050507@sandia.gov>
	<3032884323297001561@unknownmsgid>
	<4F2C6EE6.4050008@sandia.gov>
	<CAC-hyiHSNv_VgLcyVCrJ66HxTGFNBONrmmBddJk5326dLTKgkw@mail.gmail.com>
	<4F2FFDD3.1010100@sandia.gov>
	<CAC-hyiEdAd++dQFBjPDutqipQcMXZqh4RdEEyA=v12vs6ueDxA@mail.gmail.com>
	<4F3019E9.80607@sandia.gov>
	<CAF3hT9CW7_CF4iT0cY858kgkke7Wu=TK7ULzPhFj-AW9jycyZA@mail.gmail.com>
	<4F343239.2010907@sandia.gov>
	<CAGnVnB=beb2XMB55FfG7TgBeqa4gmb=O1S54=s+V6rANeoq3ug@mail.gmail.com>
	<4F3453A7.9000408@sandia.gov>
	<CAGnVnBm1hyXfk4Wnb57j3EYTwUwjSDYtHg_zPQ86B8vorgJ4Cw@mail.gmail.com>
	<4F35388B.4070601@sandia.gov>
	<CAGnVnBmv5HovMJjejKemJwjFrGOb77dnTqLpQzHtPFU4_nrvkg@mail.gmail.com>
	<4F35A3B5.7090909@sandia.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ceph-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jim Schutt <jaschut@sandia.gov>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <4F35A3B5.7090909@sandia.gov>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 10, 2012 at 6:09 PM, Jim Schutt <jaschut@sandia.gov> wrote:
>
> [ added Cc:netdev
> =A0See http://www.spinics.net/lists/ceph-devel/msg04804.html
> =A0for the start of the thread.
> =A0-- Jim
> ]
>
>
> On 02/10/2012 10:13 AM, sridhar basam wrote:
>>
>> On Fri, Feb 10, 2012 at 10:32 AM, Jim Schutt<jaschut@sandia.gov> =A0=
wrote:
>>>
>>> On 02/09/2012 06:26 PM, sridhar basam wrote:
>>>>
>>>>
>>>> Do you mind capturing to a pcap file and providing that. Makes it
>>>> easier to analyse things. If not, i understand. If you can make do=
 the
>>>> capture on both ends, do it with a snaplen of 68 so that you get a=
ll
>>>> of the headers and there shouldn't be too much payload information=
 in
>>>> the file.
>>>
>>>
>>>
>>> I've got a pcap file for this run for this client, with snaplen 128
>>> (I thought I might need to look for ceph message headers). =A0It's =
13 MB
>>> compressed. =A0How shall I get it to you?
>>>
>>
>> Can i grab it off some webserver you control? Or you can temporarily
>> drop it into docs.google.com and add accesss from my email account?
>
>
> I tabled this for the moment while I worked on collecting
> packet traces from both ends. =A0But you'll probably want
> to see the pcap files for what I'm about to show. =A0Also,
> I think I need to add netdev to this discussion ...
>
>
>>
>>> In the meantime, I'll try to capture this from both sides.
>
>
> Here's another example, captured from both sides, with
> TSO/GSO/GRO all off, snaplen 68.
>
> This was captured from the client side. =A0Same pattern, in
> that the client sends many retransmits over a period of
> a couple minutes. =A0It's different in that the client
> seems to give up and reconnect ...
>
> 11:57:35.984024 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18109890, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:35.984032 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18112786:18114234, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:35.984038 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18114234:18115682, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:35.984120 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18112786, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:35.984129 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18115682:18117130, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:35.984135 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18117130:18118578, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:35.984143 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18115682, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:35.984148 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18118578:18120026, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:35.984153 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:35.984270 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18118578, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:35.984278 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18121474:18122922, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:35.984283 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18122922:18124370, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:35.984420 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18120026, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:35.984428 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18124370:18125818, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.184945 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.587936 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:37.393937 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:39.003937 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:42.227933 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:48.675931 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:58:01.555935 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:58:27.347945 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:59:18.867935 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 12:00:22.673029 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [P.=
], seq
> 863:1036, ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
> 12:00:22.712933 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, ack
> 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:01:02.035951 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:03:02.355941 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:05:02.675947 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:07:02.995943 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:09:03.315942 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:11:03.635948 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:13:03.961655 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [S]=
, seq
> 1551304795, win 14600, options [mss 1460,[|tcp]>
> 12:13:03.961722 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [S.=
], seq
> 2095554319, ack 1551304796, win 14480, options [mss 1460,[|tcp]>
> 12:13:03.961732 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.]=
, ack
> 1, win 14600, options [nop,nop,TS[|tcp]>
> 12:13:03.961822 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [P.=
], seq
> 1:201, ack 1, win 14600, options [nop,nop,TS[|tcp]>
> 12:13:03.961874 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [.]=
, ack
> 201, win 15544, options [nop,nop,TS[|tcp]>
> 12:13:03.962070 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [P.=
], seq
> 1:10, ack 201, win 15544, options [nop,nop,TS[|tcp]>
> 12:13:03.962077 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.]=
, ack
> 10, win 14600, options [nop,nop,TS[|tcp]>
> 12:13:03.962370 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [P.=
], seq
> 10:282, ack 201, win 15544, options [nop,nop,TS[|tcp]>
> 12:13:03.962377 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.]=
, ack
> 282, win 15544, options [nop,nop,TS[|tcp]>
> 12:13:03.962819 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [F.=
], seq
> 1036, ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
> 12:13:03.962828 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [R]=
, seq
> 2449506432, win 0, length 0
>
> Here's the same thing, captured from the server side:
>
> 11:57:36.012908 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18109890, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:36.012967 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18109890:18111338, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.012977 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18111338:18112786, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.013020 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18112786, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:36.013036 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18112786:18114234, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.013039 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18114234:18115682, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.013041 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18115682, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:36.013123 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18115682:18117130, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.013129 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18117130:18118578, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.013155 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18118578, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:36.013163 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18118578:18120026, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.013171 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.013261 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18121474:18122922, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.013281 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.]=
, ack
> 18120026, win 5792, options [nop,nop,TS[|tcp]>
> 11:57:36.013288 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18122922:18124370, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.013410 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18124370:18125818, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.213941 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:36.617001 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:37.422996 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:39.033018 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:42.257206 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:57:48.705321 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:58:01.585648 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:58:27.378231 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 11:59:18.899063 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
> 12:00:22.704018 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [P.=
], seq
> 863:1036, ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
> 12:00:22.744053 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, ack
> 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:01:02.067040 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:03:02.386981 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:05:02.705227 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:07:03.021427 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:09:03.332661 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:11:03.642409 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.]=
, seq
> 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
> 12:13:03.963373 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [S]=
, seq
> 1551304795, win 14600, options [mss 1460,[|tcp]>
> 12:13:03.963389 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [S.=
], seq
> 2095554319, ack 1551304796, win 14480, options [mss 1460,[|tcp]>
> 12:13:03.963446 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.]=
, ack
> 1, win 14600, options [nop,nop,TS[|tcp]>
> 12:13:03.963540 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [P.=
], seq
> 1:201, ack 1, win 14600, options [nop,nop,TS[|tcp]>
> 12:13:03.963547 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [.]=
, ack
> 201, win 15544, options [nop,nop,TS[|tcp]>
> 12:13:03.963700 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [P.=
], seq
> 1:10, ack 201, win 15544, options [nop,nop,TS[|tcp]>
> 12:13:03.963794 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.]=
, ack
> 10, win 14600, options [nop,nop,TS[|tcp]>
> 12:13:03.964024 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [P.=
], seq
> 10:282, ack 201, win 15544, options [nop,nop,TS[|tcp]>
> 12:13:03.964091 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.]=
, ack
> 282, win 15544, options [nop,nop,TS[|tcp]>
> 12:13:03.964438 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [F.=
], seq
> 1036, ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
> 12:13:03.964542 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [R]=
, seq
> 2449506432, win 0, length 0
>
> So if I'm reading this right, the client and server agree that
> the server ACKed 18120026 twice. =A0The client and server also
> agree that the client retransmitted 18120026:18121474 nine times
> from 11:57:36.213941 through 11:59:18.899063 (server clock).
>
> But the server never ACKed that packet. =A0Too busy?
>
> I was collecting vmstat data during the run; here's the important bit=
s:
>
> Fri Feb 10 11:56:51 MST 2012
> vmstat -w 8 16
> procs -------------------memory------------------ ---swap-- -----io--=
--
> --system-- -----cpu-------
> =A0r =A0b =A0 =A0 =A0 swpd =A0 =A0 =A0 free =A0 =A0 =A0 buff =A0 =A0 =
=A0cache =A0 si =A0 so =A0 =A0bi =A0 =A0bo =A0 in
> =A0 cs =A0us sy =A0id wa st
> 13 10 =A0 =A0 =A0 =A0 =A00 =A0 =A0 250272 =A0 =A0 =A0 =A0944 =A0 3785=
9080 =A0 =A00 =A0 =A00 =A0 =A0 7 =A05346 1098
> =A0444 =A0 2 =A05 =A092 =A01 =A00
> 88 =A08 =A0 =A0 =A0 =A0 =A00 =A0 =A0 260472 =A0 =A0 =A0 =A0944 =A0 36=
728776 =A0 =A00 =A0 =A00 =A0 =A0 0 1329838
> 257602 68861 =A019 73 =A0 5 =A04 =A00
> 100 10 =A0 =A0 =A0 =A0 =A00 =A0 =A0 241952 =A0 =A0 =A0 =A0944 =A0 360=
66536 0 0 =A0 =A0 0 1635891 340724
> 85570 =A022 68 =A0 6 =A04 =A00
> 105 =A09 =A0 =A0 =A0 =A0 =A00 =A0 =A0 250288 =A0 =A0 =A0 =A0944 =A0 3=
4750820 0 0 =A0 =A0 0 1584816 433223
> 111462 =A021 73 =A0 4 =A03 =A00
> 126 =A03 =A0 =A0 =A0 =A0 =A00 =A0 =A0 259908 =A0 =A0 =A0 =A0944 =A0 3=
3841696 =A0 =A00 =A0 =A00 =A0 =A0 0 749648
> 225707 86716 =A0 9 83 =A0 4 =A03 =A00
> 157 =A02 =A0 =A0 =A0 =A0 =A00 =A0 =A0 245032 =A0 =A0 =A0 =A0944 =A0 3=
1572536 0 0 =A0 =A0 0 736841 252406
> 99083 =A0 9 81 =A0 5 =A05 =A00
> 45 17 =A0 =A0 =A0 =A0 =A00 =A0 =A0 246720 =A0 =A0 =A0 =A0944 =A0 2887=
7640 =A0 =A00 =A0 =A00 =A0 =A0 1 755085
> 282177 116551 =A0 8 77 =A0 9 =A05 =A00

Holy crap! That might explain why you aren't seeing anything. You are
writing out over a 1.6 million blocks/sec. That too averaged over a 8
second interval. I bet the missed acks are when this is happening.
What sort of I/O load is going through this system during those times?
What sort of filesystem and Linux system are these OSDs on?

 Sridhar



> 27 =A05 =A0 =A0 =A0 =A0 =A00 =A0 =A0 260556 =A0 =A0 =A0 =A0944 =A0 27=
322948 =A0 =A00 =A0 =A00 =A0 =A0 0 553263
> 232682 132427 =A0 7 68 =A019 =A06 =A00
> =A04 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 256552 =A0 =A0 =A0 =A0944 =A0 =
26507508 =A0 =A00 =A0 =A00 =A0 =A0 0 271822
> 133540 113952 =A0 5 15 =A075 =A05 =A00
> =A04 =A03 =A0 =A0 =A0 =A0 =A00 =A0 =A0 235236 =A0 =A0 =A0 =A0944 =A0 =
26308308 =A0 =A00 =A0 =A00 =A0 =A0 0 181450
> 96027 101017 =A0 4 10 =A082 =A04 =A00
> =A04 =A02 =A0 =A0 =A0 =A0 =A00 =A0 =A0 225372 =A0 =A0 =A0 =A0944 =A0 =
26072048 0 0 =A0 =A0 0 200145 97401
> 100146 =A0 4 11 =A080 =A05 =A00
> =A07 =A01 =A0 =A0 =A0 =A0 =A00 =A0 =A0 250940 =A0 =A0 =A0 =A0944 =A0 =
25974752 =A0 =A00 =A0 =A00 =A0 =A0 0 92943
> 64015 78035 =A0 3 =A07 =A087 =A02 =A00
> =A02 =A01 =A0 =A0 =A0 =A0 =A00 =A0 =A0 261712 =A0 =A0 =A0 =A0944 =A0 =
25886872 =A0 =A00 =A0 =A00 =A0 =A0 0 152351
> 80963 99512 =A0 4 =A09 =A084 =A04 =A00
> =A04 =A01 =A0 =A0 =A0 =A0 =A00 =A0 =A0 265056 =A0 =A0 =A0 =A0944 =A0 =
25850216 =A0 =A00 =A0 =A00 =A0 =A0 0 92452
> 60790 75949 =A0 3 =A07 =A087 =A02 =A00
> =A00 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 269164 =A0 =A0 =A0 =A0944 =A0 =
25857592 =A0 =A00 =A0 =A00 =A0 =A0 0 87396
> 52994 67057 =A0 3 =A07 =A088 =A03 =A00
> =A06 =A02 =A0 =A0 =A0 =A0 =A00 =A0 =A0 263672 =A0 =A0 =A0 =A0944 =A0 =
25846192 =A0 =A00 =A0 =A00 =A0 =A0 0 110817
> 67707 75849 =A0 3 =A08 =A086 =A03 =A00
> Fri Feb 10 11:58:51 MST 2012
> vmstat -w 8 16
> procs -------------------memory------------------ ---swap-- -----io--=
--
> --system-- -----cpu-------
> =A0r =A0b =A0 =A0 =A0 swpd =A0 =A0 =A0 free =A0 =A0 =A0 buff =A0 =A0 =
=A0cache =A0 si =A0 so =A0 =A0bi =A0 =A0bo =A0 in
> =A0 cs =A0us sy =A0id wa st
> =A01 =A02 =A0 =A0 =A0 =A0 =A00 =A0 =A0 260620 =A0 =A0 =A0 =A0944 =A0 =
25838996 =A0 =A00 =A0 =A00 =A0 =A0 6 =A07199 =A0240
> =A0795 =A0 3 =A08 =A088 =A01 =A00
> =A01 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 262124 =A0 =A0 =A0 =A0944 =A0 =
25838936 =A0 =A00 =A0 =A00 =A0 =A0 0 108113
> 64640 75751 =A0 3 =A07 =A087 =A03 =A00
> =A01 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 258700 =A0 =A0 =A0 =A0944 =A0 =
25850148 =A0 =A00 =A0 =A00 =A0 =A0 0 94477
> 57952 68787 =A0 3 =A07 =A088 =A03 =A00
> =A00 =A01 =A0 =A0 =A0 =A0 =A00 =A0 =A0 270144 =A0 =A0 =A0 =A0944 =A0 =
25794068 =A0 =A00 =A0 =A00 =A0 =A0 0 92113
> 54901 73329 =A0 3 =A06 =A088 =A02 =A00
> =A02 =A02 =A0 =A0 =A0 =A0 =A00 =A0 =A0 272036 =A0 =A0 =A0 =A0944 =A0 =
25768044 =A0 =A00 =A0 =A00 =A0 =A0 0 57449
> 45552 61373 =A0 3 =A05 =A090 =A02 =A00
> =A01 =A01 =A0 =A0 =A0 =A0 =A00 =A0 =A0 270024 =A0 =A0 =A0 =A0944 =A0 =
25832600 =A0 =A00 =A0 =A00 =A0 =A0 0 47651
> 44594 60577 =A0 2 =A05 =A091 =A01 =A00
> =A01 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 280648 =A0 =A0 =A0 =A0944 =A0 =
25862304 =A0 =A00 =A0 =A00 =A0 =A0 1 54773
> 42668 58636 =A0 2 =A06 =A090 =A02 =A00
> =A01 =A01 =A0 =A0 =A0 =A0 =A00 =A0 =A0 272132 =A0 =A0 =A0 =A0944 =A0 =
25848136 =A0 =A00 =A0 =A00 =A0 =A0 0 41938
> 42310 57425 =A0 3 =A06 =A091 =A01 =A00
> =A02 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 291272 =A0 =A0 =A0 =A0944 =A0 =
25806644 =A0 =A00 =A0 =A00 =A0 =A0 1 41896
> 42259 58833 =A0 2 =A05 =A091 =A01 =A00
> =A00 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 289392 =A0 =A0 =A0 =A0944 =A0 =
25804128 =A0 =A00 =A0 =A00 =A0 =A0 0 32031
> 36699 51119 =A0 2 =A05 =A092 =A01 =A00
> =A02 =A01 =A0 =A0 =A0 =A0 =A00 =A0 =A0 288420 =A0 =A0 =A0 =A0944 =A0 =
25824956 =A0 =A00 =A0 =A00 =A0 =A0 0 42997
> 40542 55109 =A0 2 =A05 =A091 =A01 =A00
> =A02 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 289076 =A0 =A0 =A0 =A0944 =A0 =
25832792 =A0 =A00 =A0 =A00 =A0 =A0 0 31843
> 36438 49974 =A0 2 =A04 =A092 =A01 =A00
> =A01 =A01 =A0 =A0 =A0 =A0 =A00 =A0 =A0 294600 =A0 =A0 =A0 =A0944 =A0 =
25795512 =A0 =A00 =A0 =A00 =A0 =A0 0 35685
> 39307 56293 =A0 2 =A05 =A092 =A01 =A00
> =A03 =A01 =A0 =A0 =A0 =A0 =A00 =A0 =A0 268708 =A0 =A0 =A0 =A0944 =A0 =
25937656 =A0 =A00 =A0 =A00 =A0 =A0 0 148219
> 79498 87394 =A0 4 =A08 =A085 =A03 =A00
> =A02 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 300100 =A0 =A0 =A0 =A0944 =A0 =
25928888 =A0 =A00 =A0 =A00 =A0 =A0 0 87999
> 59708 73501 =A0 3 =A06 =A088 =A02 =A00
> =A01 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 279988 =A0 =A0 =A0 =A0944 =A0 =
25966636 =A0 =A00 =A0 =A00 =A0 =A0 0 71014
> 52225 69119 =A0 3 =A06 =A090 =A02 =A00
>
> So the server might have been busy when 18120026:18121474 was first
> received, but it was nearly idle for several of the retransmits.
>
> What am I missing?
>
>
>>>
>>>
>>>>
>>>> I will take a look at the additional output and see if anything po=
ps
>>>> out. I am assuming the below output was immediately after what you
>>>> posted in your earlier email.
>>
>>
>> i don't see anything out of the ordinary once things recover, the
>> sender even starts to do TSO after a short while.
>
>
> That's what I thought as well.
>
> Thanks -- Jim
>
>
>>
>> =A0Sridhar
>>
>>
>>>
>>>
>>> Yes.
>>>
>>> Thanks -- Jim
>>>
>>>
>>>>
>>>>
>>>> =A0Sridhar
>>>>
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe ceph-deve=
l" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>
>>
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe ceph-devel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe ceph-devel" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
