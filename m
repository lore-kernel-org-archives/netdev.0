From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Strange samples/bpf loading error for maps on net-next?
Date: Thu, 27 Apr 2017 13:15:42 +0200
Message-ID: <20170427131542.3c8dfa24@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <borkmann@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753603AbdD0LPr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 07:15:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To provoke this bug, remember that you MUST call:

 make headers_install

In the kernels root directory, else you will be compiling samples/bpf/
against the older headers previously installed.

The error looks like:

 $ sudo ./sockex1
 bpf_load_program() err=22
 fd 0 is not pointing to valid bpf_map
 sockex1: [...]/samples/bpf/sockex1_user.c:26: main: Assertion `setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, prog_fd, sizeof(prog_fd[0])) == 0' failed.
 Aborted

I've found that the bug were introduced in
 commit: fb30d4b71214 ("bpf: Add tests for map-in-map")

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
