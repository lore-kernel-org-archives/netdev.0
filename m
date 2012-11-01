From: Bob Liu <lliubbo@gmail.com>
Subject: Re: [uclinux-dist-devel] [PATCH RFC net-next 2/4] bfin_mac: replace
 sys time stamps with raw ones instead.
Date: Thu, 1 Nov 2012 16:54:30 +0800
Message-ID: <CAA_GA1f=2ubb1z6rr1L8TR54cwh1NQcKiiaZqqv2r3mjX1wL7g@mail.gmail.com>
References: <cover.1348851539.git.richardcochran@gmail.com>
	<84396eacd75b4abed36a7819d8c2c33f9ced1ad5.1348851539.git.richardcochran@gmail.com>
	<CAA_GA1dWgav0fP3wJNFQW=VE9Qh-V8NBHqsmNoXaRny+5dnewg@mail.gmail.com>
	<20121030134112.GB2283@netboy.at.omicron.at>
	<CAA_GA1fW2zA2j66y7zfVe6+U-pb1=3mOyFFH+oDHimMFAXyH7Q@mail.gmail.com>
	<20121031083652.GC2327@netboy.at.omicron.at>
	<CAA_GA1cQojiaJat8gGmp3XYZVGOtKi2xoFS08hsYTGssdbWcRg@mail.gmail.com>
	<20121031124638.GA14197@netboy.at.omicron.at>
	<CAA_GA1eLXajk+wfwf7QYVoabDDeXLZecaTFX+6JRyoaYOyztQQ@mail.gmail.com>
	<20121101084111.GC2637@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Miroslav Lichvar <mlichvar@redhat.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	device-drivers-devel@blackfin.uclinux.org,
	Jacob Keller <jacob.e.keller@intel.com>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Patrick Ohly <patrick.ohly@intel.com>,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34889 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab2KAIyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 04:54:32 -0400
Received: by mail-wg0-f42.google.com with SMTP id fm10so101620wgb.1
        for <netdev@vger.kernel.org>; Thu, 01 Nov 2012 01:54:30 -0700 (PDT)
In-Reply-To: <20121101084111.GC2637@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 1, 2012 at 4:41 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Thu, Nov 01, 2012 at 10:08:01AM +0800, Bob Liu wrote:
>> How to use it?
>
> ptp4l -i eth0 -q -v     # master
> ptp4l -i eth0 -q -v -s  # slave
>
> #
> # Wait for state s2 on the slave_________
> #                                        \
> ptp4l[336.203]: master offset        569 s2 adj +102784 path delay 33666
> #
> # Then start phc2sys.
> #
>
> phc2sys -s /dev/ptp0
>
>> But this can't work.
>
> Can you post the output of the ptp4l and phc2sys on the slave?
>

I opened three consoles on slave machine using telnet:
console 1:
root:~> ptp4l -i eth0 -q -v -s
ptp4l[75.904]: selected /dev/ptp0 as PTP clock
ptp4l[75.908]: m
ptp4l[75.908]: driver rejected most general HWTSTAMP filter
ptp4l[75.908]: port 1: INITIALIZING to LISTENING on INITIALIZE
ptp4l[75.912]: port 0: INITIALIZING to LISTENING on INITIALIZE
ptp4l[76.244]: port 1: new foreign master 00e022.fffe.fe8529-1
ptp4l[80.252]: selected best master clock 00e022.fffe.fe8529
ptp4l[80.252]: port 1: LISTENING to UNCALIBRATED on RS_SLAVE
ptp4l[81.288]: master offset -17688624512 s0 adj      +0 path delay       7456
ptp4l[82.292]: master offset -17688618592 s0 adj      +0 path delay       7456
ptp4l[83.296]: master offset -17688613232 s0 adj      +0 path delay       7584
ptp4l[84.300]: master offset -17688607696 s1 adj      +0 path delay       7584
ptp4l[85.304]: master offset       4736 s2 adj   +4736 path delay
 7584
ptp4l[85.308]: port 1: UNCALIBRATED to SLAVE on MASTER_CLOCK_SELECTED
ptp4l[86.308]: master offset       5600 s2 adj   +7021 path delay       7584
ptp4l[87.312]: master offset       2582 s2 adj   +5683 path delay       9066
ptp4l[88.316]: master offset       2370 s2 adj   +6245 path delay       9262
ptp4l[89.320]: master offset       1568 s2 adj   +6154 path delay       9424
ptp4l[90.324]: master offset        880 s2 adj   +5937 path delay       9424
ptp4l[91.328]: master offset        680 s2 adj   +6001 path delay       9512
ptp4l[92.332]: master offset        165 s2 adj   +5690 path delay       9595
ptp4l[93.336]: master offset        -59 s2 adj   +5515 path delay       9595
ptp4l[94.340]: master offset        -12 s2 adj   +5545 path delay       9644
ptp4l[95.344]: master offset        -95 s2 adj   +5458 path delay       9679
ptp4l[96.348]: master offset         49 s2 adj   +5574 path delay       9679
ptp4l[97.352]: master offset       -143 s2 adj   +5396 path delay       9935


After see s2 state, i start phc2sys in console 2:
root:~> phc2sys -s /dev/ptp0
phc   3421792 s1 46.828595280 drift 0.00
phc   3430512 s2 47.832595280 drift 0.00
phc   3436256 s3 48.836595280 drift 0.00
phc   3454080 s4 49.840595280 drift 10719.79
phc    -37919 s4 50.841130481 drift -655.91
phc     10983 s4 51.845157639 drift 2638.99
phc      7277 s4 52.849147421 drift 4822.09
phc     12694 s4 53.853137462 drift 8630.29
phc     -6028 s4 54.857119908 drift 6821.89
phc     -7998 s4 55.861117234 drift 4422.49
phc     -2657 s4 56.865118399 drift 3625.39
phc     -5072 s4 57.869116640 drift 2103.79
phc     23391 s4 58.873118079 drift 9121.09
phc     -8035 s4 59.877092589 drift 6710.59
phc    -68278 s4 60.881091402 drift -13772.81
phc     53773 s4 61.881152717 drift 2359.09
phc     25317 s4 62.885112965 drift 9954.19
phc     19080 s4 63.889085128 drift 15678.19
phc     -6000 s4 64.893055984 drift 13878.19
phc    -17746 s4 65.897046190 drift 8554.39
phc    -13533 s4 66.901050019 drift 4494.49
phc     14260 s4 67.905055012 drift 8772.49
phc     -7786 s4 68.909036278 drift 6436.69


Then in console 3:
root:~> date
Thu Jan  1 00:00:58 UTC 1970
root:~> date
Thu Jan  1 00:00:59 UTC 1970
root:~> date
Thu Jan  1 00:00:59 UTC 1970
root:~> date
Thu Jan  1 00:01:01 UTC 1970
root:~> date
Thu Jan  1 00:01:01 UTC 1970
root:~> date
Thu Jan  1 00:01:14 UTC 1970

date in master side is:
root:/> date
Thu Dec 21 01:34:26 UTC 2006
root:/>

So the system time didn't sync.

-- 
Thanks,
--Bob
