From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 3/8] bpf: Allow cgroup sock filters to use
 get_current_uid_gid helper
Date: Tue, 22 Aug 2017 18:49:53 -0700
Message-ID: <20170823014952.kzohk4jsdua3fsds@ast-mbp>
References: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
 <1503447621-27997-4-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35908 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752923AbdHWBt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 21:49:56 -0400
Received: by mail-pf0-f194.google.com with SMTP id c15so334775pfm.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 18:49:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503447621-27997-4-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 05:20:16PM -0700, David Ahern wrote:
> Allow BPF programs run on sock create to use the get_current_uid_gid
> helper.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

as far as i understand socket creation path the context of
inet_create/inet6_create should always have valid uid/gid,
so i think the patch is fine, but please add a comment to make
sure all future callsites where BPF_CGROUP_RUN_PROG_INET_SOCK()
called will be evaluated for this matter.
