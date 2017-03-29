From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next v6 01/11] bpf: Add eBPF program subtype and
 is_valid_subtype() verifier (fwd)
Date: Wed, 29 Mar 2017 17:14:11 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1703291712590.2989@hadrien>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="8323329-221869612-1490800451=:2989"
Cc: linux-kernel@vger.kernel.org,
        =?ISO-8859-15?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan
To: =?ISO-8859-15?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-221869612-1490800451=:2989
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

Size is unsigned, so not negative.

julia

---------- Forwarded message ----------
Date: Wed, 29 Mar 2017 23:06:01 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next v6 01/11] bpf: Add eBPF program subtype and
    is_valid_subtype() verifier

In-Reply-To: <20170328234650.19695-2-mic@digikod.net>
TO: "Mickaël Salaün" <mic@digikod.net>

Hi Mickaël,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Micka-l-Sala-n/Landlock-LSM-Toward-unprivileged-sandboxing/20170329-211258
:::::: branch date: 2 hours ago
:::::: commit date: 2 hours ago

>> kernel/bpf/syscall.c:1041:5-9: WARNING: Unsigned expression compared with zero: size < 0

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 07d282aef4f60235407284c0be81d01e352e040b
vim +1041 kernel/bpf/syscall.c

f4324551 Daniel Mack        2016-11-23  1025  		return -EINVAL;
f4324551 Daniel Mack        2016-11-23  1026  	}
f4324551 Daniel Mack        2016-11-23  1027
7f677633 Alexei Starovoitov 2017-02-10  1028  	return ret;
f4324551 Daniel Mack        2016-11-23  1029  }
f4324551 Daniel Mack        2016-11-23  1030  #endif /* CONFIG_CGROUP_BPF */
f4324551 Daniel Mack        2016-11-23  1031
99c55f7d Alexei Starovoitov 2014-09-26  1032  SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
99c55f7d Alexei Starovoitov 2014-09-26  1033  {
99c55f7d Alexei Starovoitov 2014-09-26  1034  	union bpf_attr attr = {};
99c55f7d Alexei Starovoitov 2014-09-26  1035  	int err;
99c55f7d Alexei Starovoitov 2014-09-26  1036
1be7f75d Alexei Starovoitov 2015-10-07  1037  	if (!capable(CAP_SYS_ADMIN) && sysctl_unprivileged_bpf_disabled)
99c55f7d Alexei Starovoitov 2014-09-26  1038  		return -EPERM;
99c55f7d Alexei Starovoitov 2014-09-26  1039
07d282ae Mickaël Salaün     2017-03-29  1040  	size = check_user_buf((void __user *)uattr, size, sizeof(attr));
07d282ae Mickaël Salaün     2017-03-29 @1041  	if (size < 0)
07d282ae Mickaël Salaün     2017-03-29  1042  		return size;
99c55f7d Alexei Starovoitov 2014-09-26  1043
99c55f7d Alexei Starovoitov 2014-09-26  1044  	/* copy attributes from user space, may be less than sizeof(bpf_attr) */
99c55f7d Alexei Starovoitov 2014-09-26  1045  	if (copy_from_user(&attr, uattr, size) != 0)
99c55f7d Alexei Starovoitov 2014-09-26  1046  		return -EFAULT;
99c55f7d Alexei Starovoitov 2014-09-26  1047
99c55f7d Alexei Starovoitov 2014-09-26  1048  	switch (cmd) {
99c55f7d Alexei Starovoitov 2014-09-26  1049  	case BPF_MAP_CREATE:

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
--8323329-221869612-1490800451=:2989--
