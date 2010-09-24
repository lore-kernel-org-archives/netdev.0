From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [ABI REVIEW][PATCH 0/8] Namespace file descriptors
Date: Fri, 24 Sep 2010 15:49:48 +0200
Message-ID: <4C9CAC7C.2080900@free.fr>
References: <m1ocborgq7.fsf@fess.ebiederm.org> <4C9CA16F.3000505@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ulrich Drepper <drepper@gmail.com>, netdev@vger.kernel.org,
	Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>,
	linux-fsdevel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	Ben Greear <greearb@candelatech.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C9CA16F.3000505@mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/24/2010 03:02 PM, Andrew Lutomirski wrote:
> Eric W. Biederman wrote:
>> Introduce file for manipulating namespaces and related syscalls.
>> files:
>> /proc/self/ns/<nstype>
>>
>> syscalls:
>> int setns(unsigned long nstype, int fd);
>> socketat(int nsfd, int family, int type, int protocol);
>>
>
> How does security work?  Are there different kinds of fd that give (say) pin-the-namespace permission, socketat permission, and setns permission?

AFAICS, socketat, setns and "set netns by fd" only accept fd from 
/proc/<pid>/ns/<ns>.

setns does :

	file = proc_ns_fget(fd);
	if (IS_ERR(file))
		return PTR_ERR(file);

proc_ns_fget checks if (file->f_op != &ns_file_operations)


socketat and get_net_ns_by_fd:

	net = get_net_ns_by_fd(fd);

this one calls proc_ns_fget.

We have the guarantee here, the fd is resulting from an open of the file 
with the right permissions.

Another way to pin the namespace, would be to mount --bind 
/proc/<pid>/ns/<ns> but we have to be root to do that ...
