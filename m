From: jamal <hadi@cyberus.ca>
Subject: Re: [Lse-tech] Re: A common layer for Accounting packages
Date: 28 Feb 2005 08:40:10 -0500
Message-ID: <1109598010.2188.994.camel@jzny.localdomain>
References: <421CEC38.7010008@sgi.com> <421EB299.4010906@ak.jp.nec.com>
	 <20050224212839.7953167c.akpm@osdl.org> <20050227094949.GA22439@logos.cnet>
	 <4221E548.4000008@ak.jp.nec.com> <20050227140355.GA23055@logos.cnet>
	 <42227AEA.6050002@ak.jp.nec.com>
	 <1109575236.8549.14.camel@frecb000711.frec.bull.fr>
	 <20050227233943.6cb89226.akpm@osdl.org>
	 <1109592658.2188.924.camel@jzny.localdomain>
	 <20050228132051.GO31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
        Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
        kaigai@ak.jp.nec.com, marcelo.tosatti@cyclades.com,
        "David S. Miller" <davem@redhat.com>, jlan@sgi.com,
        lse-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, elsa-devel@lists.sourceforge.net
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050228132051.GO31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


netlink broadcast or a wrapper around it.
Why even bother doing the check with netlink_has_listeners()?

cheers,
jamal

On Mon, 2005-02-28 at 08:20, Thomas Graf wrote:
> > Havent seen the beginnings of this thread. But whatever you are trying
> > to do seems to suggest some complexity that you are trying to
> > workaround. What was wrong with just going ahead and just always
> > invoking your netlink_send()?
> 
> I guess parts of the wheel are broken and need to be reinvented ;->
> 
> > If there are nobody in user space (or kernel) listening, it wont go anywhere.
> 
> Additional you may want to extend netlink a bit to check whether
> there is a listener before creating the messages. The method to do so
> depends on whether you use netlink_send() or netlink_brodacast(). The
> latter is more flexiable because you can add more groups later on
> and the userspace applications can decicde which ones they want to
> listen to. Both methods handle dying clients perfectly fine, the
> association to the netlink socket gets destroyed as soon as the socket
> is closed. Therefore you can simply check mc_list of the netlink
> protocol you use to see if there are any listeners registered:
> 
> static inline int netlink_has_listeners(struct sock *sk)
> {
> 	int ret;
> 
> 	read_lock(&nl_table_lock);
> 	ret = list_empty(&nl_table[sk->sk_protocol].mc_list)
> 	read_unlock(&nl_table_lock);
> 
> 	return !ret;
> }
> 
> This is simplified and ignores the actual group assignments, i.e. you
> might want to extend it to have it check if there are listeners for
> a certain group.
> 
