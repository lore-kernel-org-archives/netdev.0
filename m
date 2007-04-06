From: "Way Chuang Ang" <wcang79@gmail.com>
Subject: low TCP throughput for small MTU and high delay
Date: Fri, 6 Apr 2007 15:42:54 +0800
Message-ID: <51d384e10704060042o56c7df6dw6b21259c5a8a1f9b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:4162 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767543AbXDFHm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 03:42:56 -0400
Received: by wx-out-0506.google.com with SMTP id h31so848744wxd
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2007 00:42:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I encountered a strange behaviour during iperf TCP test. When I set
MTU of ethernet device to 170 and incurred a delay of 250ms via netem
on sender's side, the throughput was 115Kbps. From the output of
tcp_probe the snd_cwnd peaked and stayed at 50 for the whole duration
of the test and snd_ssthresh was 100. It never went pass slow start.
>From the output of the sender is always hindered by the small window
size of 5824 bytes advertised by the receiver.

Under the same situation where all the environment variables were
same, I set MTU of sender to 180 and repeated the iperf test. It
managed to achieve average throughput of 2.18Mbps. snd_cwnd (1252)
managed to exceed snd_ssthresh (1117). The weird thing is the receiver
advertised a bigger window size of 371968, thus sender can send more
data before waiting for acknowledgement.

So my question is what causes the receiver to advertise bigger window
size for 180 byte MTU? If you have any explanation for this behaviour,
please tell. The sender advertised MSS of 256bytes for both MTU sizes.
I tried TCP hybla as well, but the throughput results were the same
with the default (BIC).

Both sender (x86 - 32 bit) and receiver  (x86- 64bit) are Fedora Core
6 machines. Brief specs of these machines:
Distro: FC6
Kernel version: 2.6.18-1.2849
Processor: Intel P4 2.8 GHz

Thank you in advance.

Regards,
Ang Way Chuang
--------------------------
aka Idiot
