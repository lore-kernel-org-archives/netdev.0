From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: Xtables: idletimer target implementation
Date: Wed, 2 Jun 2010 14:54:30 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006021444480.14585@obet.zrqbmnf.qr>
References: <1275479897-16779-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	kaber@trash.net, Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275479897-16779-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-06-02 13:58, Luciano Coelho wrote:
>+
>+#ifndef _XT_IDLETIMER_H
>+#define _XT_IDLETIMER_H
>+
>+#define MAX_LABEL_SIZE 32
>+
>+struct idletimer_tg_info {
>+	unsigned int timeout;
>+
>+	char label[MAX_LABEL_SIZE];
>+};

As per "Writing Netfilter Modules" e-book, using "int" is a no-no.

> 
>+config NETFILTER_XT_TARGET_IDLETIMER
>+	tristate  "IDLETIMER target support"

depends on NETFILTER_ADVANCED

>xt_IDLETIMER.c
>+struct idletimer_tg_attr {
>+        struct attribute attr;
>+	ssize_t	(*show)(struct kobject *kobj,
>+			struct attribute *attr, char *buf);
>+};

Some indent seems to have gone wrong.

>+	attr->attr.name = kstrdup(info->label, GFP_KERNEL);

Need to check return value!

>+	attr->attr.mode = 0444;

attr->attr.mode = S_IRUGO;

>+static struct xt_target idletimer_tg __read_mostly = {
>+	.name		= "IDLETIMER",
>+	.family		= NFPROTO_IPV4,

NFPROTO_UNSPEC

>+	.target		= idletimer_tg_target,
>+	.targetsize     = sizeof(struct idletimer_tg_info),
>+	.checkentry	= idletimer_tg_checkentry,
>+	.destroy        = idletimer_tg_destroy,
>+	.me		= THIS_MODULE,
>+};
>+
>+static int __init idletimer_tg_init(void)
>+{
>+	int ret;
>+
>+	idletimer_tg_kobj = kobject_create_and_add("idletimer",
>+						   &THIS_MODULE->mkobj.kobj);
>+	if (!idletimer_tg_kobj)
>+		return -ENOMEM;
>+
>+	/* FIXME: do we want to keep it in the module or in the net class? */

I have only ever seen interfaces in /sys/class/net, so it might be
wise to keep it that way in light of scripts doing 
echo /sys/class/net/*  to get a list of interfaces.


Looks quite ok.
