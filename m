From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Fri, 30 May 2003 23:32:29 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030530.233229.08331783.davem@redhat.com>
References: <3ED80230.2030508@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com
In-Reply-To: <3ED80230.2030508@us.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Krishna Kumar <krkumar@us.ibm.com>
   Date: Fri, 30 May 2003 18:15:28 -0700

This code is so gross..
   
   +/* prefix list returned to user space in this structure */
   +struct plist_user_info {
   +	char name[IFNAMSIZ];		/* interface name */
   +	int ifindex;			/* interface index */

Just as Yoshfuji said, name is determinable with ifindex alone.
Don't duplicate information.

   +	struct var_plist_user_info {	/* multiple elements */
   +		char flags[3];		/* router advertised flags */

BARF

   +#ifdef CONFIG_IPV6_PREFIXLIST
   +	BUG_TRAP(list_empty(&idev->prefix_list) == 1);
   +#endif

list_empty() returns a boolean, which for true is not necessarily the
integer value "1".  This will therefore never trigger when it should
on cpus which use "-1" as the boolean value true.

You have all of this complexity which duplicates work made by
the routing code to keep track of these kinds of entities.

Your "takes a long time to walk the routes" argument is NULL
and void, what if I have 6,000 VLAN interfaces configured up
speaking ipv6?  This is not a hypothetical situation, I know
people who do this.

If you're worried about search complexity, you can keep the
"interesting" routes on a special linked list to avoid having to walk
all of the routes.  These prefix things really do seem like route
attributes.

That is 1,000 times cleaner than this thing you are showing us.
