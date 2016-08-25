From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v2 08/10] landlock: Handle file system comparisons
Date: Thu, 25 Aug 2016 04:12:02 -0700
Message-ID: <CALCETrWzfgNvOHmKy5205A2qLJLYCZ+5RZOQR9vzQ1ubpo0vNA@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net> <1472121165-29071-9-git-send-email-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Arnd Bergmann <arnd@arndb.de>, Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
	David Drysdale <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
	Elena Reshetova <elena.reshetova@intel.com>, James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
	Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linux API <linux-api@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <kernel-hardening-return-4464-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-9-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> Add eBPF functions to compare file system access with a Landlock file
> system handle:
> * bpf_landlock_cmp_fs_prop_with_struct_file(prop, map, map_op, file)
>   This function allows to compare the dentry, inode, device or mount
>   point of the currently accessed file, with a reference handle.
> * bpf_landlock_cmp_fs_beneath_with_struct_file(opt, map, map_op, file)
>   This function allows an eBPF program to check if the current accessed
>   file is the same or in the hierarchy of a reference handle.
>
> The goal of file system handle is to abstract kernel objects such as a
> struct file or a struct inode. Userland can create this kind of handle
> thanks to the BPF_MAP_UPDATE_ELEM command. The element is a struct
> landlock_handle containing the handle type (e.g.
> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) and a file descriptor. This could
> also be any descriptions able to match a struct file or a struct inode
> (e.g. path or glob string).

This needs Eric's opinion.

Also, where do all the struct file *'s get stashed?  Are they
preserved in the arraymap?  What prevents reference cycles or absurdly
large numbers of struct files getting pinned?

--Andy
