From: Joe Perches <joe@perches.com>
Subject: [rfc] Remove member .name from struct netpoll
Date: Fri, 01 Jul 2011 10:07:51 -0700
Message-ID: <1309540071.7277.63.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct netpoll has member .name

struct netpoll {
	struct net_device *dev;
	char dev_name[IFNAMSIZ];
	const char *name;
[...]
};

that is set only by netconsole.c

static struct netconsole_target *alloc_param_target(char *target_config)
{
[...]
	nt->np.name = "netconsole";

and used only by net/core/netpoll.c to emit "netconsole: " on
logging messages.

e.g.

void netpoll_print_options(struct netpoll *np)
{
	printk(KERN_INFO "%s: local port %d\n",
			 np->name, np->local_port);

I think it'd be more common to use pr_fmt and pr_<level>
to emit these logging messages.

Are there out of tree users or plans to use "struct netpoll"
by other modules?

If not, I propose to remove name from the struct.
