From: Zilvinas Valinskas <zilvinas@gemtek.lt>
Subject: Crypto tests via tcrypt.o modules failes
Date: Thu, 16 Sep 2004 21:11:22 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095358282.3359.83.camel@swoop.gemtek.lt>
Reply-To: zilvinas@gemtek.lt
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, 

I've got here Xscale IXP425, vanilla linux 2.4.27 + ipsec + Xscale arch
patch (I use IPsec patch backported from 2.6 kernel by Herbert Xu).  
I've successfully compiled kernel, and booted on Xscale and Intel CPUs.

Loaded encryption modules and ran 'insmod tcrypt.o' to verify if
encryption is fine. Not all tests went through. 

Details are here,http://www.gemtek.lt/~zilvinas/crypto/tcrypt-tests

Further testing reveals :
1. AH with 'Null' encryption and w/o IPComp  works just fine. 

2. I've tried ESP with AES-CBC.
2.1  <Xscale> <-> <Xscale> no luck, computers can't ping each other.
  (the same linux 2.4.27 + ipsec kernel on both boards).

2.2  <Xscale> <-> <Intel> , the same 2.4.27 + ipsec kernel was used,
  compiled for a different architectures though. No luck either.

2.3  <Xscale> <-> <Intel 2.6.9-rc1> - no luch either.

2.4  <Intel - 2.4.27 + ipsec> <-> <Intel - 2.6.9-rc1> success, 
   with ESP/AES-CBC, AH  ... 


Does it mean, crypto is not big-endian safe/clean ? 
 
Any pointers where to start or ideas how to track and fix - are welcome.
(I don't have much expertise here though .. Never too late to start
learning).

I would say Xscale IXP425 has a rather interesting 32, 16 bits
read/write results if address is not aligned properly. In the same
directory - http://www.gemtek.lt/~zilvinas/crypto/ i've put *.pdf
describing what exactly is happening. 

Perhaps that is a culprit ?

Thank you, I appreciate any help.

ps.
I am not subscribed to netdev@oss.sgi.com, please keep me on CC:
