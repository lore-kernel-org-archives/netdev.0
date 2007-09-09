From: Stjepan Gros <sgros@zemris.fer.hr>
Subject: Question about NAT-T and PF_KEY...
Date: Sun, 09 Sep 2007 22:30:13 +0200
Message-ID: <1189369814.19024.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ikev2-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iluvatar.zemris.fer.hr ([161.53.65.13]:44026 "EHLO
	iluvatar.zemris.fer.hr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794AbXIIUx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 16:53:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I'm having problems telling the kernel to do ESP-in-UDP encapsulation.
Outgoing direction seems to work, but the incoming packets on the other
side are passed to ikev2 daemon instead of kernel decapsulating them.

The only strange thing I'm noticing for now is the difference between
setkey and ip command outputs. In the ip command output the following
line appears (complete output is at the end of this mail).

encap type espinudp sport 4500 dport 4500 addr 111.0.0.0

with strange address, 111.0.0.0, for which I don't know the purpose and
also I don't know from where it came from. Also, I don't know how to
manipulate that address via PF_KEY!

Any help would be very appreciated! In case this is not detailed enough
to point to the problem, I can send more information.

Thanks,
Stjepan

# ip xfrm state sh
src 10.0.0.2 dst 192.168.0.2
        proto esp spi 0x8e19037d reqid 0 mode tunnel
        replay-window 0 
        auth sha1 0xf928fc8f76092e08238934d1caa1d78f8d144bd8
        enc des3_ede 0xc8a8d5cd9ea831854c37e02f54e6916d79fb575834bc5854
        encap type espinudp sport 4500 dport 4500 addr 111.0.0.0
src 192.168.0.2 dst 10.0.0.2
        proto esp spi 0x41a5ebfc reqid 0 mode tunnel
        replay-window 0 
        auth sha1 0xa7a5a366761812cfee2c5855fd95aef87c2e3411
        enc des3_ede 0xbc045267fd15c78c57aeada27f0bdc970164e69751083b51
        encap type espinudp sport 4500 dport 4500 addr 111.0.0.0

10.0.0.2[4500] 192.168.0.2[4500] 
        esp-udp mode=tunnel spi=2384003965(0x8e19037d)
reqid=0(0x00000000)
        E: 3des-cbc  c8a8d5cd 9ea83185 4c37e02f 54e6916d 79fb5758
34bc5854
        A: hmac-sha1  f928fc8f 76092e08 238934d1 caa1d78f 8d144bd8
        seq=0x00000000 replay=0 flags=0x00000000 state=mature 
        created: Sep  9 20:11:45 2007   current: Sep  9 20:12:11 2007
        diff: 26(s)     hard: 0(s)      soft: 0(s)
        last: Sep  9 20:11:45 2007      hard: 0(s)      soft: 0(s)
        current: 432(bytes)     hard: 0(bytes)  soft: 0(bytes)
        allocated: 3    hard: 0 soft: 0
        sadb_seq=1 pid=16076 refcnt=0
192.168.0.2[4500] 10.0.0.2[4500] 
        esp-udp mode=tunnel spi=1101392892(0x41a5ebfc)
reqid=0(0x00000000)
        E: 3des-cbc  bc045267 fd15c78c 57aeada2 7f0bdc97 0164e697
51083b51
        A: hmac-sha1  a7a5a366 761812cf ee2c5855 fd95aef8 7c2e3411
        seq=0x00000000 replay=0 flags=0x00000000 state=mature 
        created: Sep  9 20:11:45 2007   current: Sep  9 20:12:11 2007
        diff: 26(s)     hard: 0(s)      soft: 0(s)
        last:                           hard: 0(s)      soft: 0(s)
        current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
        allocated: 0    hard: 0 soft: 0
        sadb_seq=0 pid=16076 refcnt=0

