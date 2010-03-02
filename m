From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Tue, 2 Mar 2010 13:19:42 -0800
Message-ID: <20100302211942.GA17816@us.ibm.com>
References: <4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org> <4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr> <4B8D28CF.8060304@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Ben Greear <greearb@candelatech.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:34457 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752276Ab0CBVNd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 16:13:33 -0500
Content-Disposition: inline
In-Reply-To: <4B8D28CF.8060304@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov [xemul@parallels.com] wrote:
| > I agree with all the points you and Pavel you talked about but I don't 
| > feel comfortable to have the current process to switch the pid namespace 
| > because of the process tree hierarchy (what will be the parent of the 
| > process when you enter the pid namespace for example).
| 
| The answer is - the one, that used to be. I see no problems with it.
| Do you?

Just to be clear, when a process unshares its pid namespace, it takes
on additional pid nr (== 1) in the new namespace but retains its original
pid nr(s) in the parent (ancestor) namespaces right ?

i.e the process becomes the container-init of the new namespace. When it
exits, all its children belonging to the new namespace are killed too,
but any children in the parent namespace (i.e children created before
unshare()) are not killed.

After the unshare() the process will not be able to signal any children
it created before the unshare() (bc their active pid namespaces are
different)

Sukadev
