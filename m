From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: [2.6.10] Known bug ? TCP Ack "storm"
Date: Thu, 17 Feb 2005 11:25:02 +1030
Message-ID: <20050217112502.06861a40.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On a couple of occasions (yesterday, just now, and a few weeks ago),
I've had what I'll call a TCP ack "storm". I'm not sure about the other
occasions, however, today, it occured while I was accessing the
Cisco.com web site.

It persists for quite a while, and seems to take a few minutes to
disappear, although it eventually stopping might have been because I
closed my browser down.

Here is are 30 lines of output from tethereal. I have a capture file
with around 180 examples, there were a lot more than that problably in
the 1000s  :


--
  1   0.000000 198.133.219.25 -> 210.84.229.252 TCP www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
  2   0.000167 210.84.229.252 -> 198.133.219.25 TCP [TCP ACKed lost segment] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
  3   0.211857 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#1] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
  4   0.211996 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#1] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
  5   0.424007 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#2] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
  6   0.424151 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#2] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
  7   0.635641 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#3] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
  8   0.635766 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#3] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
  9   0.848265 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#4] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 10   0.848396 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#4] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 11   1.062668 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#5] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 12   1.062800 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#5] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 13   1.280399 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#6] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 14   1.280528 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#6] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 15   1.490076 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#7] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 16   1.490208 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#7] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 17   1.702436 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#8] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 18   1.702567 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#8] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 19   1.914104 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#9] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 20   1.914231 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#9] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 21   2.128192 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#10] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 22   2.128321 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#10] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 23   2.349868 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#11] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 24   2.350008 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#11] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 25   2.563787 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#12] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 26   2.563915 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#12] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 27   2.776169 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#13] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 28   2.776293 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#13] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
 29   2.987558 198.133.219.25 -> 210.84.229.252 TCP [TCP Dup ACK 1#14] www > 52065 [ACK] Seq=0 Ack=0 Win=65340 Len=0
 30   2.987708 210.84.229.252 -> 198.133.219.25 TCP [TCP Dup ACK 2#14] 52065 > www [ACK] Seq=0 Ack=1267 Win=20048 Len=0
--

I can provide the packet trace file if required. Download it from the
following URL. I had to fool Geocities to allow me to upload it, so it
isn't a PDF, it's just a bzip2'ed tcpdump packet trace file.

http://au.geocities.com/markzzzsmith/tcpackstorm.pdf

Thanks,
Mark.

-- 

    "This signature intentionally left blank."
