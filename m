From: "Dan A. Dickey" <dan.dickey@savvis.net>
Subject: TCP Hang (or close to it):  Windows XP -> Linux (w/tcp_bic)
Date: Fri, 29 Oct 2004 09:25:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410290925.48955.dan.dickey@savvis.net>
Reply-To: dan.dickey@savvis.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All,
We are able to reproduce what appears to be a tcp hang with
Windows XP sending to a Linux box (2.6.7 kernel) that has
tcp_bic turned on.  At the moment, I'm unsure that tcp_bic
has anything to do with it - I'll be testing with tcp_bic turned
off today to see if I can reproduce this problem or not.

I'm looking for someone to help me determine what the
cause of this hang is - I have a 3MB ethereal capture file
that I can send if you think you can help out.  Let me know,
and I'll send you the file and some more information about
the application and what we are doing.

Just in case this might help you to figure it out,
here is a small portion of the display from ethereal at
the point of failure.   192.168.168.126 is the Windows
XP machine, and 192.168.168.25 is the Linux box.

14:25:58.260109 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1101042 win 39272
14:25:58.260116 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1102502 win 42192
14:25:58.260133 IP 192.168.168.126.2519 > 192.168.168.25.15100: . 
1102502:1103962(1460) ack 1 win 65535
14:25:58.260143 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1103962 win 45112
14:25:58.260147 IP 192.168.168.126.2519 > 192.168.168.25.15100: . 
1103962:1105422(1460) ack 1 win 65535
14:25:58.260155 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1105422 win 48032
14:25:58.260184 IP 192.168.168.126.2519 > 192.168.168.25.15100: . 
1105422:1106882(1460) ack 1 win 65535
14:25:58.260191 IP 192.168.168.126.2519 > 192.168.168.25.15100: . 
1106882:1108342(1460) ack 1 win 65535
14:25:58.260206 IP 192.168.168.126.2519 > 192.168.168.25.15100: . 
1108342:1109802(1460) ack 1 win 65535
14:25:58.260228 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1106882 win 50952
14:25:58.260252 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1108342 win 53872
14:25:58.260273 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1109802 win 56792
14:25:58.260279 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1111262 win 59712
14:25:58.260286 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1112722 win 62632
14:25:58.260293 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1114182 win 16
14:25:58.260348 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1114506 win 16
14:25:58.534331 IP 192.168.168.126.2451 > 192.168.168.25.15100: . 
160:176(16) ack 1 win 65535
14:25:58.534493 IP 192.168.168.25.15100 > 192.168.168.126.2451: . ack 
176 win 16
14:26:03.237624 IP 192.168.168.126.2519 > 192.168.168.25.15100: . 
1114506:1114522(16) ack 1 win 65535
14:26:03.237803 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1114522 win 16
14:26:03.565752 IP 192.168.168.126.2451 > 192.168.168.25.15100: . 
176:192(16) ack 1 win 65535
14:26:03.565914 IP 192.168.168.25.15100 > 192.168.168.126.2451: . ack 
192 win 16
14:26:08.269049 IP 192.168.168.126.2519 > 192.168.168.25.15100: . 
1114522:1114538(16) ack 1 win 65535
14:26:08.269217 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1114538 win 16
14:26:08.597185 IP 192.168.168.126.2451 > 192.168.168.25.15100: . 
192:208(16) ack 1 win 65535
14:26:08.597347 IP 192.168.168.25.15100 > 192.168.168.126.2451: . ack 
208 win 16
14:26:13.300469 IP 192.168.168.126.2519 > 192.168.168.25.15100: . 
1114538:1114554(16) ack 1 win 65535
14:26:13.300640 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1114554 win 16
14:26:13.628603 IP 192.168.168.126.2451 > 192.168.168.25.15100: . 
208:224(16) ack 1 win 65535
14:26:13.628774 IP 192.168.168.25.15100 > 192.168.168.126.2451: . ack 
224 win 16
14:26:18.331909 IP 192.168.168.126.2519 > 192.168.168.25.15100: . 
1114554:1114570(16) ack 1 win 65535
14:26:18.332075 IP 192.168.168.25.15100 > 192.168.168.126.2519: . ack 
1114570 win 16
14:26:18.660013 IP 192.168.168.126.2451 > 192.168.168.25.15100: . 
224:240(16) ack 1 win 65535
14:26:18.660174 IP 192.168.168.25.15100 > 192.168.168.126.2451: . ack 
240 win 16


I'm not sure how well this is going to come across, but as I said - I
can send the capture file.  Please help!  Thanks in advance.
(My concern is the window on the Linux side dropping from 62632
to 16 at the 14:25:58.260293 point - this just doesn't seem right).
 -Dan

-- 
Dan A. Dickey
dan.dickey@savvis.net

SAVVIS
Transforming Information Technology
