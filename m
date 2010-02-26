From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Fri, 26 Feb 2010 13:49:08 -0800
Message-ID: <m1k4tzvfaj.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B883987.6090408@parallels.com>
	<m1bpfbwuze.fsf@fess.ebiederm.org> <4B883EAF.5020607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45451 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966217Ab0BZVtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 16:49:17 -0500
In-Reply-To: <4B883EAF.5020607@parallels.com> (Pavel Emelyanov's message of "Sat\, 27 Feb 2010 00\:35\:43 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@parallels.com> writes:

> Eric W. Biederman wrote:
>> Pavel Emelyanov <xemul@parallels.com> writes:
>> 
>>>> +static struct inode *nsfd_mkinode(void)
>>>> +{
>>>> +	struct inode *inode;
>>>> +	inode = new_inode(nsfd_mnt->mnt_sb);
>>>> +	if (!inode)
>>>> +		return ERR_PTR(-ENOMEM);
>>>> +
>>>> +	inode->i_fop = &nsfd_file_operations;
>>>> +
>>>> +	/*
>>>> +	 * Mark the inode dirty from the very beginning,
>>>> +	 * that way it will never be moved to the dirty
>>>> +	 * list because mark_inode_dirty() will think that
>>>> +	 * it already _is_ on the dirty list.
>>>> +	 */
>>>> +	inode->i_state = I_DIRTY;
>>>> +	inode->i_mode = S_IRUSR | S_IWUSR;
>>>> +	inode->i_uid = current_fsuid();
>>>> +	inode->i_gid = current_fsgid();
>>>> +	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>>>> +	return inode;
>>>> +}
>>> Why not use anon inodes?
>> 
>> Because you can't mount them anywhere.
>
> Worth changing them that way?

I don't think so.  They keep all of their state in struct file.  To be
usefully bind mounted you need to keep your state in the dentry or the
inode.

Ultimately what I have done is fix rootfs so it supports bind mounts and
used rootfs inodes.

Eric

