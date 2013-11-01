From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch -next] bonding: bond_get_size() returns wrong size
Date: Fri, 01 Nov 2013 03:52:48 -0700
Message-ID: <1383303168.19864.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131101101844.GA29795@longonot.mountain>
	 <20131101104100.GU692@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20131101104100.GU692@redhat.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-01 at 11:41 +0100, Veaceslav Falico wrote:
> On Fri, Nov 01, 2013 at 01:18:44PM +0300, Dan Carpenter wrote:
> >There is an extra semi-colon so bond_get_size() doesn't return the
> >correct value.
> >
> >Fixes: ec76aa49855f ('bonding: add Netlink support active_slave option')
> >Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Hrm, how does it even build. Good catch, thanks.
> 
> Acked-by: Veaceslav Falico <vfalico@redhat.com>

Yep, an alternative is to use following format :

static inline size_t br_port_info_size(void)
{
        return nla_total_size(1)        /* IFLA_BRPORT_STATE  */
                + nla_total_size(2)     /* IFLA_BRPORT_PRIORITY */
                + nla_total_size(4)     /* IFLA_BRPORT_COST */
                + nla_total_size(1)     /* IFLA_BRPORT_MODE */
                + nla_total_size(1)     /* IFLA_BRPORT_GUARD */
                + nla_total_size(1)     /* IFLA_BRPORT_PROTECT */
                + nla_total_size(1)     /* IFLA_BRPORT_FAST_LEAVE */
                + nla_total_size(1)     /* IFLA_BRPORT_LEARNING */
                + nla_total_size(1)     /* IFLA_BRPORT_UNICAST_FLOOD */
                + 0;
}

So that a patch adding a new attribute doesn't have to change the 'last
line'

 

