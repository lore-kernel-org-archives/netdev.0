From: =?iso-8859-1?q?Bartek=20Wydrowski?= <b_wydrowski@yahoo.com.au>
Subject: RFC1323. No timestamping if SYN timestamp = 0. Bug or Feature?
Date: Thu, 23 Oct 2003 06:01:52 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031022200152.17005.qmail@web13006.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-309782246-1066852912=:16989"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0-309782246-1066852912=:16989
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit


Dear NetDev,

I have noticed that when my Windows XP PC makes a TCP connection to my Linux PC, the Windows PC sends a timestamp option with timestamp value 0 in the starting SYN- and linux seems to ignore this timestamp and does not communicate with timestamp option
for the rest of the connection. There appears to be code in the TCP_IPV4.C file which checks for this condition and ignores timestamps if rcv_tsval == 0.  I have included this code, as well as the TCP dump of this behaviour at the bottom.

a) Is there a reason why Linux should not do timestamps if timestamp value in SYN is zero?
b) Does this not cause problems with Windows and Linux RFC1323
compatibility? (It seems like windows sends timestamp 0 in SYN packet perhaps as a rule).
c) Can this test condition be removed without other consequences?

Indeed I removed the condition and then a Windows initiated connection was able to talk timestamps with Linux with no problems. Why do we need this (timestamp=0 in SYN) exclusion in the first place?

Thanks
Bartek Wydrowski


Kernel Code: in tcp_ipv4.c
----------------------------

if (tp.saw_tstamp && tp.rcv_tsval == 0) {
                /* Some OSes (unknown ones, but I see them on web server,
which
                 * contains information interesting only for windows'
                 * users) do not send their stamp in SYN. It is easy case.
                 * We simply do not advertise TS support.
                 */
                tp.saw_tstamp = 0;
                tp.tstamp_ok = 0;
}

TCPdump of this behaviour:
-----------------------------

windows XP Box > Linux Box 1991982409:199198240 9(0) win 64240 <mss
1460,nop,wscale 0,nop,nop,timestamp 0 0,nop,nop,sackOK> (DF)

Linux Box > windows XP Box S 2478701299:247870129 9(0) ack 1991982410 win
5840 <mss 1460,nop,nop,sackOK,nop,wscale 8> (DF)





---------------------------------
Yahoo! Personals
- New people, new possibilities. FREE for a limited time!
--0-309782246-1066852912=:16989
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: 8bit

<P>Dear NetDev,<BR><BR>I have noticed that when my Windows XP PC makes a TCP connection to my Linux PC, the Windows PC sends a timestamp option with timestamp value 0 in the starting SYN- and linux seems to ignore this timestamp and does not communicate with timestamp option<BR>for the rest of the connection. There appears to be code in the TCP_IPV4.C file which checks for this condition and ignores timestamps if rcv_tsval == 0.&nbsp; I have included this code, as well as the TCP dump of this behaviour at the bottom.<BR><BR>a) Is there a reason why Linux should not do timestamps if timestamp value in SYN is zero?<BR>b) Does this not cause problems with Windows and Linux RFC1323<BR>compatibility? (It seems like windows sends timestamp 0 in SYN packet perhaps as a rule).<BR>c) Can this test condition be removed without other consequences?<BR><BR>Indeed I removed the condition and then a Windows initiated connection was able to talk timestamps with Linux with no problems. Why d!
 
 o we need
 this (timestamp=0 in SYN) exclusion in the first place?</P>
<P>Thanks<BR>Bartek Wydrowski<BR><BR><BR>Kernel Code: in tcp_ipv4.c<BR>----------------------------<BR><BR>if (tp.saw_tstamp &amp;&amp; tp.rcv_tsval == 0) {<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Some OSes (unknown ones, but I see them on web server,<BR>which<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * contains information interesting only for windows'<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * users) do not send their stamp in SYN. It is easy case.<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * We simply do not advertise TS support.<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; */<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; tp.saw_tstamp =
 0;<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; tp.tstamp_ok = 0;<BR>}<BR><BR>TCPdump of this behaviour:<BR>-----------------------------<BR><BR>windows XP Box &gt; Linux Box 1991982409:199198240 9(0) win 64240 &lt;mss<BR>1460,nop,wscale 0,nop,nop,timestamp 0 0,nop,nop,sackOK&gt; (DF)<BR><BR>Linux Box &gt; windows XP Box S 2478701299:247870129 9(0) ack 1991982410 win<BR>5840 &lt;mss 1460,nop,nop,sackOK,nop,wscale 8&gt; (DF)<BR></P>
<DIV></DIV><p><br><hr size=1>
<a href="http://au.rd.yahoo.com/mail/welcome/*http://au.personals.yahoo.com" target=_blank><b>Yahoo! Personals</b></a><br>
- New people, new possibilities. FREE for a limited time!
--0-309782246-1066852912=:16989--
