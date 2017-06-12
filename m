From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Build issues for samples/bpf/ after rebase or git pull (solved)
Date: Mon, 12 Jun 2017 15:17:22 +0200
Message-ID: <20170612151722.7717a7b8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: brouer@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49182 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751796AbdFLNRd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Jun 2017 09:17:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi XDP newbies (and Google-search),

Just gotten bitten by this common build error issue.  I git rebased my work
on a newer kernel, and is now getting build errors for make samples/bpf/.
Which fails with compile errors (see below), for tools/lib/bpf/bpf.c.

 The solution is to (re)run:  make headers_install

As described in[1]: samples/bpf/README.rst, we need to run make headers_install.
This will creates a local "usr/include" directory in the git/build top
level directory, that the make system automatically pickup first.  And
when rebasing or pulling latest git changes, we have to remember to
rerun this, if bpf header files changed.

 [1] https://github.com/torvalds/linux/blob/master/samples/bpf/README.rst

p.s. Hope this will help other hitting this issue, seeding the bpf / XDP info pool ;-)
- - 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer


$ make
make -C ../../ /home/jbrouer/git/kernel/net-next/samples/bpf/
make[1]: Entering directory '/home/jbrouer/git/kernel/net-next'
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CHK     scripts/mod/devicetable-offsets.h
  LD      /home/jbrouer/git/kernel/net-next/samples/bpf/built-in.o
  HOSTCC  /home/jbrouer/git/kernel/net-next/samples/bpf/test_lru_dist.o
  HOSTCC  /home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.o
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c: In function ‘bpf_verify_program’:
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:137:6: error: ‘union bpf_attr’ has no member named ‘prog_flags’; did you mean ‘map_flags’?
  attr.prog_flags = strict_alignment ? BPF_F_STRICT_ALIGNMENT : 0;
      ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:137:39: error: ‘BPF_F_STRICT_ALIGNMENT’ undeclared (first use in this function)
  attr.prog_flags = strict_alignment ? BPF_F_STRICT_ALIGNMENT : 0;
                                       ^~~~~~~~~~~~~~~~~~~~~~
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:137:39: note: each undeclared identifier is reported only once for each function it appears in
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c: In function ‘bpf_prog_get_next_id’:
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:267:6: error: ‘union bpf_attr’ has no member named ‘start_id’; did you mean ‘target_fd’?
  attr.start_id = start_id;
      ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:269:16: error: ‘BPF_PROG_GET_NEXT_ID’ undeclared (first use in this function)
  err = sys_bpf(BPF_PROG_GET_NEXT_ID, &attr, sizeof(attr));
                ^~~~~~~~~~~~~~~~~~~~
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:271:18: error: ‘union bpf_attr’ has no member named ‘next_id’; did you mean ‘next_key’?
   *next_id = attr.next_id;
                  ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c: In function ‘bpf_map_get_next_id’:
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:282:6: error: ‘union bpf_attr’ has no member named ‘start_id’; did you mean ‘target_fd’?
  attr.start_id = start_id;
      ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:284:16: error: ‘BPF_MAP_GET_NEXT_ID’ undeclared (first use in this function)
  err = sys_bpf(BPF_MAP_GET_NEXT_ID, &attr, sizeof(attr));
                ^~~~~~~~~~~~~~~~~~~
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:286:18: error: ‘union bpf_attr’ has no member named ‘next_id’; did you mean ‘next_key’?
   *next_id = attr.next_id;
                  ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c: In function ‘bpf_prog_get_fd_by_id’:
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:296:6: error: ‘union bpf_attr’ has no member named ‘prog_id’; did you mean ‘prog_type’?
  attr.prog_id = id;
      ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:298:17: error: ‘BPF_PROG_GET_FD_BY_ID’ undeclared (first use in this function)
  return sys_bpf(BPF_PROG_GET_FD_BY_ID, &attr, sizeof(attr));
                 ^~~~~~~~~~~~~~~~~~~~~
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c: In function ‘bpf_map_get_fd_by_id’:
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:306:6: error: ‘union bpf_attr’ has no member named ‘map_i ’; did you mean ‘map_fd’?
  attr.map_id = id;
      ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:308:17: error: ‘BPF_MAP_GET_FD_BY_ID’ undeclared (first use in this function)
  return sys_bpf(BPF_MAP_GET_FD_BY_ID, &attr, sizeof(attr));
                 ^~~~~~~~~~~~~~~~~~~~
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c: In function ‘bpf_obj_get_info_by_fd’:
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:318:6: error: ‘union bpf_attr’ has no member named ‘info’
  attr.info.bpf_fd = prog_fd;
      ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:319:6: error: ‘union bpf_attr’ has no member named ‘info’
  attr.info.info_len = *info_len;
      ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:320:6: error: ‘union bpf_attr’ has no member named ‘info’
  attr.info.info = ptr_to_u64(info);
      ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:322:16: error: ‘BPF_OBJ_GET_INFO_BY_FD’ undeclared (first use in this function)
  err = sys_bpf(BPF_OBJ_GET_INFO_BY_FD, &attr, sizeof(attr));
                ^~~~~~~~~~~~~~~~~~~~~~
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:324:19: error: ‘union bpf_attr’ has no member named ‘info’
   *info_len = attr.info.info_len;
                   ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c: In function ‘bpf_prog_get_fd_by_id’:
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:299:1: warning: control reaches end of non-void function  -Wreturn-type]
 }
 ^
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c: In function ‘bpf_map_get_fd_by_id’:
/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.c:309:1: warning: control reaches end of non-void function  -Wreturn-type]
 }
 ^
scripts/Makefile.host:124: recipe for target '/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.o' failed
make[2]: *** [/home/jbrouer/git/kernel/net-next/samples/bpf/../../tools/lib/bpf/bpf.o] Error 1
Makefile:1683: recipe for target '/home/jbrouer/git/kernel/net-next/samples/bpf/' failed
make[1]: *** [/home/jbrouer/git/kernel/net-next/samples/bpf/] Error 2
make[1]: Leaving directory '/home/jbrouer/git/kernel/net-next'
Makefile:157: recipe for target 'all' failed
make: *** [all] Error 2
