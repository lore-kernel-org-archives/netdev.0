From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Thu, 08 Jul 2004 12:49:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40ED7B18.800@nortelnetworks.com>
References: <20040708162703.GA12934@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040902000407060804000806"
Cc: Andi Kleen <ak@suse.de>, Michael T Kerrisk <mtk-lists@gmx.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: aeb@cwi.nl
In-Reply-To: <20040708162703.GA12934@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040902000407060804000806
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Andi Kleen wrote:
> On Thu, Jul 08, 2004 at 12:21:35PM -0400, Chris Friesen wrote:
>  > Michael T Kerrisk wrote:
>  >
>  > >MSG_DONTWAIT should also work with recvmsg().
>  >
>  > Hmm...  Just tried it with a DGRAM socket, and it seems to work.  Any 
> ideas
>  > why its not in the man pages?
> 
> Nobody ever added it? Just send a patch to aeb@cwi.nl

Sending patch as suggested.  Fundamentally, the delta is as follows, I've 
included an attachment with what I hope are the proper formatting codes (copied 
from send(2)).

--- recv.man    2004-07-08 15:43:17.000000000 -0400
+++ recv2.man   2004-07-08 15:47:29.000000000 -0400
@@ -67,6 +67,11 @@
                disconnect occurs, or the next data to be received is of a  dif-
                ferent type than that returned.

+       MSG_DONTWAIT
+              Enables  non-blocking  operation;  if the operation would block,
+              EAGAIN is returned (this can also be enabled  using  the  O_NON-
+              BLOCK with the F_SETFL fcntl(2)).
+
         MSG_NOSIGNAL
                This  flag  turns  off raising of SIGPIPE on stream sockets when
                the other end disappears.


Note also that there is a mention of MSG_DONTWAIT in the msg_flags field in the 
msghdr.  It gives the impression that one can *set* that field to cause the 
non-blocking behaviour.  My understanding is that the msg_flags field is a 
return value only.  Perhaps that portion should be reworded as well.

Chris

--------------040902000407060804000806
Content-Type: application/octet-stream;
 name="man2recv.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="man2recv.diff"

LS0tIHJlY3YubWFuCTIwMDQtMDctMDggMTU6NDM6MTcuMDAwMDAwMDAwIC0wNDAwCisrKyBy
ZWN2Mi5tYW4JMjAwNC0wNy0wOCAxNTo0NzoyOS4wMDAwMDAwMDAgLTA0MDAKQEAgLTY3LDYg
KzY3LDExIEBACiAgICAgICAgICAgICAgIGRpc2Nvbm5lY3Qgb2NjdXJzLCBvciB0aGUgbmV4
dCBkYXRhIHRvIGJlIHJlY2VpdmVkIGlzIG9mIGEgIGRpZi0KICAgICAgICAgICAgICAgZmVy
ZW50IHR5cGUgdGhhbiB0aGF0IHJldHVybmVkLgogCisgICAgICAgTQhNUwhTRwhHXwhfRAhE
TwhPTghOVAhUVwhXQQhBSQhJVAhUCisgICAgICAgICAgICAgIEVuYWJsZXMgIG5vbi1ibG9j
a2luZyAgb3BlcmF0aW9uOyAgaWYgdGhlIG9wZXJhdGlvbiB3b3VsZCBibG9jaywKKyAgICAg
ICAgICAgICAgRQhFQQhBRwhHQQhBSQhJTghOIGlzIHJldHVybmVkICh0aGlzIGNhbiBhbHNv
IGJlIGVuYWJsZWQgIHVzaW5nICB0aGUgIE8IT18IX04ITk8IT04ITi0ILQorICAgICAgICAg
ICAgICBCCEJMCExPCE9DCENLCEsgd2l0aCB0aGUgRghGXwhfUwhTRQhFVAhURghGTAhMIGYI
ZmMIY24IbnQIdGwIbCgyKSkuCisKICAgICAgICBNCE1TCFNHCEdfCF9OCE5PCE9TCFNJCElH
CEdOCE5BCEFMCEwKICAgICAgICAgICAgICAgVGhpcyAgZmxhZyAgdHVybnMgIG9mZiByYWlz
aW5nIG9mIFMIU0kISUcIR1AIUEkISVAIUEUIRSBvbiBzdHJlYW0gc29ja2V0cyB3aGVuCiAg
ICAgICAgICAgICAgIHRoZSBvdGhlciBlbmQgZGlzYXBwZWFycy4K
--------------040902000407060804000806--
