From: Meelis Roos <mroos@linux.ee>
Subject: iptables broken on ppc (ptrace too?) (2.6.17-rc3)
Date: Sun, 14 May 2006 18:31:24 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605141822260.26018@math.ut.ee>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-559023410-758783491-1147620684=:26018"
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:50376 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751456AbWENPb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 May 2006 11:31:27 -0400
To: netdev@vger.kernel.org, vger.kernel.org@ut.ee
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---559023410-758783491-1147620684=:26018
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 8BIT

Iptables seems to be broken on ppc for me. Kernel 2.6.17-rc3 (currently 
compiling rc4+git). 32-bit ppc, ARCH=ppc with PReP target. Iptables 
userland binary is from the latest Debian unstable (1.3.3-2).

The symptoms: iptables usually just tells Invalid Argument on any 
modification attempt. I'm trying to set up a simple one-rule NAT for 
test:
iptables -t nat -A POSTROUTING -s 172.30.0.0/24 -j SNAT --to 10.0.0.1
and it usually fails but has succeeded 2 times (I now have 2 rules of 
this kind and they seem to just wotk once set up). Trying to delete the 
second rule (either by replacing -A with -D or using just -D 2) gives 
the same error.

Trying to strace the iptables just left me one D state iptables in 
page_fault and I also got a SIGSEGV with strace from iptables just at 
the beginning (trace is below) - so it appears ptrace on ppc might also 
be broken.

Nothing in dmesg.

execve("/sbin/iptables", ["iptables", "-t", "nat", "-D", "POSTROUTING", "2"], [/* 14 vars */]) = 0
uname({sys="Linux", node="muuseum", ...}) = 0
brk(0)                                  = 0x1001d000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x30019000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=21161, ...}) = 0
mmap(NULL, 21161, PROT_READ, MAP_PRIVATE, 3, 0) = 0x3001a000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/tls/libdl.so.2", O_RDONLY)   = 3
read(3, "\177ELF\1\2\1\0\0\0\0\0\0\0\0\0\0\3\0\24\0\0\0\1\0\0\r@\0\0\0004\0\0001\224\0\0\0\0\0004\0 \0\10\0(\0\34\0\33\0\0\0\6\0\0\0004\0\0\0004\0\0\0004\0\0\1\0\0\0\1\0\0\0\0\5\0\0\0\4\0\0\0\3\0\0 \230\0\0 \230\0\0 \230\0\0\0\20\0\0\0\20\0\0\0\4\0\0\0\4\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0 \254\0\0 \254\0\0\0\5\0\1\0\0\0\0\0\1\0\0.\354\0\1.\354\0\1.\354\0\0\1\260\0\0\3\0\0\0\0\7\0\1\0\0\0\0\0\2\0\0/ \0\1/ \0\1/ \0\0\0\340\0\0\0\340\0\0\0\6\0\0\0\4\0\0\0\4\0\0\0014\0\0\0014\0\0\0014\0\0\0 \0\0\0 \0\0\0\4\0\0\0\4dt\345Q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\6\0\0\0\4dt\345R\0\0.\354\0\1.\354\0\1.\354\0\0\1\24\0\0\1\24\0\0\0\5\0\0\0\4\0\0\0\4\0\0\0\20\0\0\0\1GNU\0\0\0\0\0\0\0\0\2\0\0\0\6\0\0\0\0\0\0\0K\0\0\0005\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0-\0\0\0&\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\'\0\0\0\23\0\0\0\34\0\0\0004\0\0\0\0\0\0\0\0\0\0\0.\0\0\0\
 17\0\0\0\0\0\0\0,\0\0\0\0\0\0\0\0\0\0\0+\0\0\0\0\0\0\0(\0\0\0\0\0\0\0 \0\0\0\0\0\0\0#\0\0!
\0\0\0\0\0\0\0\0\0\24\0\0\0\0\0\0\0\26\0\0\0\37\0\0\0002\0\0\0!", 512) = 512
fstat64(3, {st_mode=S_IFREG|0644, st_size=13812, ...}) = 0
mmap(0xffdc000, 78316, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xffdc000
mprotect(0xffdf000, 66028, PROT_NONE)   = 0
mmap(0xffee000, 8192, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0xffee000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/tls/libnsl.so.1", O_RDONLY)  = 3
read(3, "\177ELF\1\2\1\0\0\0\0\0\0\0\0\0\0\3\0\24\0\0\0\1\0\0>@\0\0\0004\0\1J0\0\0\0\0\0004\0 \0\10\0(\0\35\0\34\0\0\0\6\0\0\0004\0\0\0004\0\0\0004\0\0\1\0\0\0\1\0\0\0\0\5\0\0\0\4\0\0\0\3\0\1>d\0\1>d\0\1>d\0\0\0\20\0\0\0\20\0\0\0\4\0\0\0\4\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\1>x\0\1>x\0\0\0\5\0\1\0\0\0\0\0\1\0\1>\354\0\2>\354\0\2>\354\0\0\n@\0\0/\224\0\0\0\7\0\1\0\0\0\0\0\2\0\1?(\0\2?(\0\2?(\0\0\0\330\0\0\0\330\0\0\0\6\0\0\0\4\0\0\0\4\0\0\0014\0\0\0014\0\0\0014\0\0\0 \0\0\0 \0\0\0\4\0\0\0\4dt\345Q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\6\0\0\0\4dt\345R\0\1>\354\0\2>\354\0\2>\354\0\0\1\24\0\0\1\24\0\0\0\5\0\0\0\4\0\0\0\4\0\0\0\20\0\0\0\1GNU\0\0\0\0\0\0\0\0\2\0\0\0\6\0\0\0\0\0\0\1\303\0\0\0\365\0\0\0\0\0\0\0@\0\0\0\210\0\0\0\0\0\0\0\0\0\0\0\35\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0q\0\0\0\0\0\0\0n\0\0\0\323\0\0\0\266\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\246\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0*\0\0\
 0\304\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\232\0\0\0\0\0\0\0\0\0!
\0\0\0\0\0\0008\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\25", 512) = 512
fstat64(3, {st_mode=S_IFREG|0644, st_size=85688, ...}) = 0
mmap(0xffa5000, 159360, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xffa5000
mprotect(0xffb9000, 77440, PROT_NONE)   = 0
mmap(0xffc8000, 8192, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13000) = 0xffc8000
mmap(0xffca000, 7808, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xffca000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/tls/libc.so.6", O_RDONLY)    = 3
read(3, "\177ELF\1\2\1\0\0\0\0\0\0\0\0\0\0\3\0\24\0\0\0\1\0\1\314\220\0\0\0004\0\25,\364\0\0\0\0\0004\0 \0\n\0(\0?\0>\0\0\0\6\0\0\0004\0\0\0004\0\0\0004\0\0\1@\0\0\1@\0\0\0\5\0\0\0\4\0\0\0\3\0\24o\350\0\24o\350\0\24o\350\0\0\0\20\0\0\0\20\0\0\0\4\0\0\0\4\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\24\204\r\0\24\204\r\0\0\0\5\0\1\0\0\0\0\0\1\0\24\204\320\0\25\204\320\0\25\204\320\0\0\236D\0\0\306\274\0\0\0\7\0\1\0\0\0\0\0\2\0\24\357\30\0\25\357\30\0\25\357\30\0\0\0\350\0\0\0\350\0\0\0\6\0\0\0\4\0\0\0\4\0\0\1t\0\0\1t\0\0\1t\0\0\0 \0\0\0 \0\0\0\4\0\0\0\4\0\0\0\7\0\24\331H\0\25\331H\0\25\331H\0\0\0\10\0\0\0(\0\0\0\4\0\0\0\4dt\345P\0\24o\370\0\24o\370\0\24o\370\0\0\17\364\0\0\17\364\0\0\0\4\0\0\0\4dt\345Q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\6\0\0\0\4dt\345R\0\24\204\320\0\25\204\320\0\25\204\320\0\0j@\0\0j@\0\0\0\5\0\0\0\4\0\0\0\4\0\0\0\20\0\0\0\1GNU\0\0\0\0\0\0\0\0\2\0\0\0\6\0\0\0\0\0\0\3\37
 7\0\0\10R\0\0\1\10\0\0\6z\0\0\0\0\0\0\0\323\0\0\6\341\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0!
\6j\0\0\5\314\0\0\0\0\0\0\10\v\0\0\6s\0\0\2\25\0\0\2\243\0\0\10\37\0\0\4\37\0\0\10\23\0\0\0\0\0\0\1\373\0\0\2z\0\0\7\342\0\0\6\26\0\0\4\300", 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=1390284, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x30020000
mmap(0xfe30000, 1461132, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xfe30000
mprotect(0xff79000, 113548, PROT_NONE)  = 0
mmap(0xff88000, 45056, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x148000) = 0xff88000
mmap(0xff93000, 7052, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xff93000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x30021000
mprotect(0xff88000, 24576, PROT_READ)   = 0
mprotect(0xffc8000, 4096, PROT_READ)    = 0
mprotect(0xffee000, 4096, PROT_READ)    = 0
mprotect(0x30028000, 4096, PROT_READ)   = 0
munmap(0x3001a000, 21161)               = 0
--- SIGSEGV (Segmentation fault) @ 0 (0) ---
+++ killed by SIGSEGV +++

-- 
Meelis Roos (mroos@linux.ee)
---559023410-758783491-1147620684=:26018--
