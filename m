From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 27 Feb 2010 00:35:43 +0300
Message-ID: <4B883EAF.5020607@parallels.com>
References: <4B4F24AC.70105@trash.net>
	<1263481549.23480.24.camel@bigi>	<4B4F3A50.1050400@trash.net>
	<1263490403.23480.109.camel@bigi>	<4B50403A.6010507@trash.net>
	<1263568754.23480.142.camel@bigi>	<m13a0tf17t.fsf@fess.ebiederm.org>
	<1266875729.3673.12.camel@bigi>	<m1wry46es9.fsf@fess.ebiederm.org>
	<1266931623.3973.643.camel@bigi>	<m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi>	<m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi>	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1bpfbwuze.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> 
>>> +static struct inode *nsfd_mkinode(void)
>>> +{
>>> +	struct inode *inode;
>>> +	inode = new_inode(nsfd_mnt->mnt_sb);
>>> +	if (!inode)
>>> +		return ERR_PTR(-ENOMEM);
>>> +
>>> +	inode->i_fop = &nsfd_file_operations;
>>> +
>>> +	/*
>>> +	 * Mark the inode dirty from the very beginning,
>>> +	 * that way it will never be moved to the dirty
>>> +	 * list because mark_inode_dirty() will think that
>>> +	 * it already _is_ on the dirty list.
>>> +	 */
>>> +	inode->i_state = I_DIRTY;
>>> +	inode->i_mode = S_IRUSR | S_IWUSR;
>>> +	inode->i_uid = current_fsuid();
>>> +	inode->i_gid = current_fsgid();
>>> +	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>>> +	return inode;
>>> +}
>> Why not use anon inodes?
> 
> Because you can't mount them anywhere.

Worth changing them that way?
