From: "Jim Schutt" <jaschut@sandia.gov>
Subject: Re: [RFC PATCH 0/6] Understanding delays due to throttling
 under very heavy write load
Date: Fri, 10 Feb 2012 16:09:41 -0700
Message-ID: <4F35A3B5.7090909@sandia.gov>
References: <1328111668-10068-1-git-send-email-jaschut@sandia.gov>
 <CAF3hT9BNc4n4HBNEqsf+d6-Rjv7TC8nJ1VponJCBVpLB8=_F5Q@mail.gmail.com>
 <4F2ADEAE.8010403@sandia.gov>
 <CAF3hT9CFkxnWR4zoTRPtyGU5CbfV_PvL+=dqnvZcr7G0HBOb+w@mail.gmail.com>
 <4F2AF085.6000405@sandia.gov>
 <CAF3hT9AcxxNtscFczP8fShSsaBm_4zhLQZ2F5c7h1YswVaXHkA@mail.gmail.com>
 <4F2C08A7.2050507@sandia.gov> <3032884323297001561@unknownmsgid>
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
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: ceph-devel@vger.kernel.org, netdev@vger.kernel.org
To: "sridhar basam" <sri@basam.org>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <CAGnVnBmv5HovMJjejKemJwjFrGOb77dnTqLpQzHtPFU4_nrvkg@mail.gmail.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[ added Cc:netdev
   See http://www.spinics.net/lists/ceph-devel/msg04804.html
   for the start of the thread.
   -- Jim
]

On 02/10/2012 10:13 AM, sridhar basam wrote:
> On Fri, Feb 10, 2012 at 10:32 AM, Jim Schutt<jaschut@sandia.gov>  wrote:
>> On 02/09/2012 06:26 PM, sridhar basam wrote:
>>>
>>> Do you mind capturing to a pcap file and providing that. Makes it
>>> easier to analyse things. If not, i understand. If you can make do the
>>> capture on both ends, do it with a snaplen of 68 so that you get all
>>> of the headers and there shouldn't be too much payload information in
>>> the file.
>>
>>
>> I've got a pcap file for this run for this client, with snaplen 128
>> (I thought I might need to look for ceph message headers).  It's 13 MB
>> compressed.  How shall I get it to you?
>>
>
> Can i grab it off some webserver you control? Or you can temporarily
> drop it into docs.google.com and add accesss from my email account?

I tabled this for the moment while I worked on collecting
packet traces from both ends.  But you'll probably want
to see the pcap files for what I'm about to show.  Also,
I think I need to add netdev to this discussion ...

>
>> In the meantime, I'll try to capture this from both sides.

Here's another example, captured from both sides, with
TSO/GSO/GRO all off, snaplen 68.

This was captured from the client side.  Same pattern, in
that the client sends many retransmits over a period of
a couple minutes.  It's different in that the client
seems to give up and reconnect ...

11:57:35.984024 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18109890, win 5792, options [nop,nop,TS[|tcp]>
11:57:35.984032 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18112786:18114234, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:35.984038 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18114234:18115682, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:35.984120 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18112786, win 5792, options [nop,nop,TS[|tcp]>
11:57:35.984129 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18115682:18117130, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:35.984135 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18117130:18118578, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:35.984143 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18115682, win 5792, options [nop,nop,TS[|tcp]>
11:57:35.984148 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18118578:18120026, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:35.984153 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:35.984270 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18118578, win 5792, options [nop,nop,TS[|tcp]>
11:57:35.984278 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18121474:18122922, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:35.984283 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18122922:18124370, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:35.984420 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
11:57:35.984428 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18124370:18125818, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.184945 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.587936 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:37.393937 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:39.003937 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:42.227933 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:48.675931 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:58:01.555935 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:58:27.347945 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:59:18.867935 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
12:00:22.673029 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [P.], seq 863:1036, ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
12:00:22.712933 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:01:02.035951 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:03:02.355941 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:05:02.675947 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:07:02.995943 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:09:03.315942 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:11:03.635948 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:13:03.961655 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [S], seq 1551304795, win 14600, options [mss 1460,[|tcp]>
12:13:03.961722 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [S.], seq 2095554319, ack 1551304796, win 14480, options [mss 1460,[|tcp]>
12:13:03.961732 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.], ack 1, win 14600, options [nop,nop,TS[|tcp]>
12:13:03.961822 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [P.], seq 1:201, ack 1, win 14600, options [nop,nop,TS[|tcp]>
12:13:03.961874 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [.], ack 201, win 15544, options [nop,nop,TS[|tcp]>
12:13:03.962070 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [P.], seq 1:10, ack 201, win 15544, options [nop,nop,TS[|tcp]>
12:13:03.962077 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.], ack 10, win 14600, options [nop,nop,TS[|tcp]>
12:13:03.962370 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [P.], seq 10:282, ack 201, win 15544, options [nop,nop,TS[|tcp]>
12:13:03.962377 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.], ack 282, win 15544, options [nop,nop,TS[|tcp]>
12:13:03.962819 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [F.], seq 1036, ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
12:13:03.962828 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [R], seq 2449506432, win 0, length 0

Here's the same thing, captured from the server side:

11:57:36.012908 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18109890, win 5792, options [nop,nop,TS[|tcp]>
11:57:36.012967 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18109890:18111338, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.012977 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18111338:18112786, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.013020 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18112786, win 5792, options [nop,nop,TS[|tcp]>
11:57:36.013036 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18112786:18114234, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.013039 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18114234:18115682, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.013041 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18115682, win 5792, options [nop,nop,TS[|tcp]>
11:57:36.013123 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18115682:18117130, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.013129 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18117130:18118578, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.013155 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18118578, win 5792, options [nop,nop,TS[|tcp]>
11:57:36.013163 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18118578:18120026, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.013171 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.013261 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18121474:18122922, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.013281 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [.], ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
11:57:36.013288 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18122922:18124370, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.013410 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18124370:18125818, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.213941 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:36.617001 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:37.422996 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:39.033018 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:42.257206 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:57:48.705321 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:58:01.585648 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:58:27.378231 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
11:59:18.899063 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 863, win 18760, options [nop,nop,TS[|tcp]>
12:00:22.704018 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [P.], seq 863:1036, ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
12:00:22.744053 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:01:02.067040 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:03:02.386981 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:05:02.705227 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:07:03.021427 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:09:03.332661 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:11:03.642409 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [.], seq 18120026:18121474, ack 1036, win 19832, options [nop,nop,TS[|tcp]>
12:13:03.963373 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [S], seq 1551304795, win 14600, options [mss 1460,[|tcp]>
12:13:03.963389 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [S.], seq 2095554319, ack 1551304796, win 14480, options [mss 1460,[|tcp]>
12:13:03.963446 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.], ack 1, win 14600, options [nop,nop,TS[|tcp]>
12:13:03.963540 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [P.], seq 1:201, ack 1, win 14600, options [nop,nop,TS[|tcp]>
12:13:03.963547 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [.], ack 201, win 15544, options [nop,nop,TS[|tcp]>
12:13:03.963700 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [P.], seq 1:10, ack 201, win 15544, options [nop,nop,TS[|tcp]>
12:13:03.963794 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.], ack 10, win 14600, options [nop,nop,TS[|tcp]>
12:13:03.964024 IP 172.17.131.32.6807 > 172.17.135.4.57628: Flags [P.], seq 10:282, ack 201, win 15544, options [nop,nop,TS[|tcp]>
12:13:03.964091 IP 172.17.135.4.57628 > 172.17.131.32.6807: Flags [.], ack 282, win 15544, options [nop,nop,TS[|tcp]>
12:13:03.964438 IP 172.17.131.32.6807 > 172.17.135.4.57589: Flags [F.], seq 1036, ack 18120026, win 5792, options [nop,nop,TS[|tcp]>
12:13:03.964542 IP 172.17.135.4.57589 > 172.17.131.32.6807: Flags [R], seq 2449506432, win 0, length 0

So if I'm reading this right, the client and server agree that
the server ACKed 18120026 twice.  The client and server also
agree that the client retransmitted 18120026:18121474 nine times
from 11:57:36.213941 through 11:59:18.899063 (server clock).

But the server never ACKed that packet.  Too busy?

I was collecting vmstat data during the run; here's the important bits:

Fri Feb 10 11:56:51 MST 2012
vmstat -w 8 16
procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
  r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
13 10          0     250272        944   37859080    0    0     7  5346 1098  444   2  5  92  1  0
88  8          0     260472        944   36728776    0    0     0 1329838 257602 68861  19 73   5  4  0
100 10          0     241952        944   36066536    0    0     0 1635891 340724 85570  22 68   6  4  0
105  9          0     250288        944   34750820    0    0     0 1584816 433223 111462  21 73   4  3  0
126  3          0     259908        944   33841696    0    0     0 749648 225707 86716   9 83   4  3  0
157  2          0     245032        944   31572536    0    0     0 736841 252406 99083   9 81   5  5  0
45 17          0     246720        944   28877640    0    0     1 755085 282177 116551   8 77   9  5  0
27  5          0     260556        944   27322948    0    0     0 553263 232682 132427   7 68  19  6  0
  4  0          0     256552        944   26507508    0    0     0 271822 133540 113952   5 15  75  5  0
  4  3          0     235236        944   26308308    0    0     0 181450 96027 101017   4 10  82  4  0
  4  2          0     225372        944   26072048    0    0     0 200145 97401 100146   4 11  80  5  0
  7  1          0     250940        944   25974752    0    0     0 92943 64015 78035   3  7  87  2  0
  2  1          0     261712        944   25886872    0    0     0 152351 80963 99512   4  9  84  4  0
  4  1          0     265056        944   25850216    0    0     0 92452 60790 75949   3  7  87  2  0
  0  0          0     269164        944   25857592    0    0     0 87396 52994 67057   3  7  88  3  0
  6  2          0     263672        944   25846192    0    0     0 110817 67707 75849   3  8  86  3  0
Fri Feb 10 11:58:51 MST 2012
vmstat -w 8 16
procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
  r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
  1  2          0     260620        944   25838996    0    0     6  7199  240  795   3  8  88  1  0
  1  0          0     262124        944   25838936    0    0     0 108113 64640 75751   3  7  87  3  0
  1  0          0     258700        944   25850148    0    0     0 94477 57952 68787   3  7  88  3  0
  0  1          0     270144        944   25794068    0    0     0 92113 54901 73329   3  6  88  2  0
  2  2          0     272036        944   25768044    0    0     0 57449 45552 61373   3  5  90  2  0
  1  1          0     270024        944   25832600    0    0     0 47651 44594 60577   2  5  91  1  0
  1  0          0     280648        944   25862304    0    0     1 54773 42668 58636   2  6  90  2  0
  1  1          0     272132        944   25848136    0    0     0 41938 42310 57425   3  6  91  1  0
  2  0          0     291272        944   25806644    0    0     1 41896 42259 58833   2  5  91  1  0
  0  0          0     289392        944   25804128    0    0     0 32031 36699 51119   2  5  92  1  0
  2  1          0     288420        944   25824956    0    0     0 42997 40542 55109   2  5  91  1  0
  2  0          0     289076        944   25832792    0    0     0 31843 36438 49974   2  4  92  1  0
  1  1          0     294600        944   25795512    0    0     0 35685 39307 56293   2  5  92  1  0
  3  1          0     268708        944   25937656    0    0     0 148219 79498 87394   4  8  85  3  0
  2  0          0     300100        944   25928888    0    0     0 87999 59708 73501   3  6  88  2  0
  1  0          0     279988        944   25966636    0    0     0 71014 52225 69119   3  6  90  2  0

So the server might have been busy when 18120026:18121474 was first
received, but it was nearly idle for several of the retransmits.

What am I missing?

>>
>>
>>>
>>> I will take a look at the additional output and see if anything pops
>>> out. I am assuming the below output was immediately after what you
>>> posted in your earlier email.
>
> i don't see anything out of the ordinary once things recover, the
> sender even starts to do TSO after a short while.

That's what I thought as well.

Thanks -- Jim

>
>   Sridhar
>
>
>>
>>
>> Yes.
>>
>> Thanks -- Jim
>>
>>
>>>
>>>
>>>   Sridhar
>>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


