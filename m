From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: IP More Fragements bit problem.
Date: Fri, 11 Feb 2005 17:08:16 +0100
Message-ID: <200502111708.16024.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Tony Reix <Tony.Reix@Bull.Net>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,

I am working on NFSv4 and I found an IP problem while doing interoperability 
testing with AIX.

The More Fragements (MF) bits is set on the last packet sent in a list of 
packets that sould be reassembled
 
For example :

If we get the A, B, C, D packets that may be reassembled into ABCD we sould 
have 

A + MF
B + MF
C + MF
D

On kernel 2.6.10rc2 and laters (last tested is 2.6.11-rc3) we have: 

A + MF
B + MF
C + MF
D + MF

That cause AIX waiting for the last packet with out sending ack
So Linux suppose  AIX didn't receive all, and re send all packets.
So AIX is receiving that: 
A + MF
B + MF
C + MF
D + MF
*DELAY *
A + MF
B + MF
C + MF
D + MF
*DELAY*
A + MF
B + MF
C + MF
D + MF
*DELAY*
...

After a while AIX destroy first fragments because of the IP fragements life 
time. Trond Myklebust said me you can do anything for that?

Cher,
Vincent ROQUETA
