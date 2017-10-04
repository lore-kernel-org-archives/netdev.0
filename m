From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/4] selinux: bpf: Add addtional check for bpf
 object file receive
Date: Thu, 05 Oct 2017 01:44:35 +0200
Message-ID: <59D57263.3080601@iogearbox.net>
References: <20171004182932.140028-1-chenbofeng.kernel@gmail.com> <20171004182932.140028-5-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20171004182932.140028-5-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/04/2017 08:29 PM, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
>
> Introduce a bpf object related check when sending and receiving files
> through unix domain socket as well as binder. It checks if the receiving
> process have privilege to read/write the bpf map or use the bpf program.
> This check is necessary because the bpf maps and programs are using a
> anonymous inode as their shared inode so the normal way of checking the
> files and sockets when passing between processes cannot work properly on
> eBPF object. This check only works when the BPF_SYSCALL is configured.

[...]
> +/* This function will check the file pass through unix socket or binder to see
> + * if it is a bpf related object. And apply correspinding checks on the bpf
> + * object based on the type. The bpf maps and programs, not like other files and
> + * socket, are using a shared anonymous inode inside the kernel as their inode.
> + * So checking that inode cannot identify if the process have privilege to
> + * access the bpf object and that's why we have to add this additional check in
> + * selinux_file_receive and selinux_binder_transfer_files.
> + */
[...]

If selinux/lsm folks have some input on this one in particular, would
be great. The issue is not really tied to bpf specifically, but to the
use of anon-inodes wrt fd passing. Maybe some generic resolution can
be found to tackle this ...
