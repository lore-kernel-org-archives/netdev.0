From: Rodolfo Giometti <giometti@enneenne.com>
Subject: Re: Generic netlink interface help
Date: Sun, 27 May 2007 19:39:59 +0200
Message-ID: <20070527173959.GU21180@enneenne.com>
References: <20070524085956.GP7089@enneenne.com> <84po8XY4.1179999810.5490870.samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-174-11-161.f5.ngi.it ([81.174.11.161]:48844 "EHLO
	mail.enneenne.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbXE0RjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 13:39:25 -0400
Content-Disposition: inline
In-Reply-To: <84po8XY4.1179999810.5490870.samuel@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 24, 2007 at 09:43:30AM -0000, Samuel Ortiz wrote:

> You could look at Johannes Berg 802.11 generic netlink implementation for
> a good example (net/wireless/nl80211.c in John Linville's tree):
> http://git.kernel.org/?p=linux/kernel/git/linville/wireless-dev.git;a=blob;f=net/wireless/nl80211.c;h=d6a44a386c2b86b81514b08d3c9b324dd2c7d229;hb=HEAD

Looking at that code I suppose that if I want send/receive "struct
pps_netlink_msg" to/from the kernel I have to define:

static struct genl_family pps_gnl_family = {
        .id      = GENL_ID_GENERATE,    /* don't bother with a hardcoded ID */
        .name    = "PPS",
        .hdrsize = 0,                   /* no private header */
        .version = PPS_FAMILY_VER,
        .maxattr = 1,
};

static struct nla_policy pps_genl_policy[1] = {
        [0] = {
                .type = NLA_BINARY,
                .len = sizeof(struct pps_netlink_msg),
        },
};

static struct genl_ops pps_gnl_ops = {
        .cmd     = 0x1,
        .policy  = pps_genl_policy,
        .doit    = pps_genl_data_ready,
};

Then the pps_genl_data_ready() should do:

static int pps_genl_data_ready(struct sk_buff *skb, struct genl_info *info)
{
        struct pps_netlink_msg *msg = nla_data(info->attrs[0]);
        int cmd, source;
        unsigned long timeout;
        int ret;

        if (!msg)
                return -EINVAL;

	/* Do the job and put the answer into
	   msg struct itself... */

	genlmsg_unicast(skb, info->snd_pid);

        return 0;
}

Is that right?

Thanks,

Rodolfo

-- 

GNU/Linux Solutions                  e-mail:    giometti@enneenne.com
Linux Device Driver                             giometti@gnudd.com
Embedded Systems                     		giometti@linux.it
UNIX programming                     phone:     +39 349 2432127
