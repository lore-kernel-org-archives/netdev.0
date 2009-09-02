From: wu xiaofei <lampsu@gmail.com>
Subject: Re: about packets forwarding
Date: Wed, 2 Sep 2009 20:31:41 +0800
Message-ID: <f4f837ab0909020531l46c001d2o8fa08f63f9525332@mail.gmail.com>
References: <f4f837ab0907220706g1129a1cbv7dfad944e5bada16@mail.gmail.com>
	 <f4f837ab0909020127o3359ed03j224ef51a0673bcd9@mail.gmail.com>
	 <f4f837ab0909020203w67bcba16pbb317c587c58e70f@mail.gmail.com>
	 <20090902201800.1dbb4988.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f204.google.com ([209.85.223.204]:60211 "EHLO
	mail-iw0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbZIBMbj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 08:31:39 -0400
Received: by iwn42 with SMTP id 42so337022iwn.33
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 05:31:41 -0700 (PDT)
In-Reply-To: <20090902201800.1dbb4988.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/9/2 Mark Smith <lk-netdev@lk-netdev.nosense.org>:
> On Wed, 2 Sep 2009 17:03:42 +0800
> wu xiaofei <lampsu@gmail.com> wrote:
>
>> Hello,
>>
>> I have something to ask here.
>>
>> The topology of the network is as follows.
>> There are six Nodes (A, B, C, D, M, N).
>>
>> =A0 M
>> =A0 |
>> =A0 A
>> =A0/ \
>> B=A0=A0 D
>> =A0\ /
>> =A0 C
>> =A0 |
>> =A0 N
>>
>> M-A, C-N are wired links.
>> A-B, B-C, A-D, D-C are wireless links.
>>
>> Node M wnats to communicate with node N. Because the wireless links
>> are not very reliable, I want to forward the packets through A-B-C a=
nd
>> A-D-C simultaneously (When Node A receives packets(from Node M) from
>> its wired interface eth0, It will forward the same packets to its
>> wireless interfaces wlan0 and wlan1 simultaneously) . How to impleme=
nt
>> this?
>>
>
> Packets being duplicated in this manner is generally considered an
> error - protocols are designed to deal with it, but only as an error
> robustness mechanism. In other words, it won't break anything, but
> performance is very likely to suffer.
>

I will process the duplicated packets on node C, just forward one copy
to node N.
My purpose:
to improve the reliablity of the wireless links, make our individual
network more robust.
If the path A-B-C is not available, maybe the path A-D-C is still
available, so the communication between node M and node N will not be
interrupted.
The probability of the path A-B-C and A-D-C broken at the same time   i=
s small.

> The Internet protocols are designed on the assumption of a low
> possibility of packet loss (1 in 100)- they only assume each
> link in the path will have an error detection mechanism (and drop the=
m
> when errors occur), but not an error correction mechanism. If the
> possibility of packet loss is high (1 in 10), then it is expected tha=
t
> the link layer itself will implement error detection and recovery.
>

We use 802.11b/g wireless cards on our nodes.
The wireless links may have varying quality in terms of packet loss,
data rates, and interference. It's not very stable. It's very
different from wired links.

--
Wu
