From: jamal <hadi@cyberus.ca>
Subject: Re: patch: introduce simple actions
Date: 20 Mar 2005 15:10:27 -0500
Message-ID: <1111349426.1092.128.camel@jzny.localdomain>
References: <1111345551.1095.82.camel@jzny.localdomain>
	 <20050320194408.GU3086@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Patrick McHardy <kaber@trash.net>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050320194408.GU3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-03-20 at 14:44, Thomas Graf wrote:
> * Jamal Hadi Salim <1111345551.1095.82.camel@jzny.localdomain> 2005-03-20 14:05

> > +static inline int
> > +tcf_defact_init(struct rtattr *rta, struct rtattr *est,
> > +		struct tc_action *a, int ovr, int bind)
> > +{
> > +	struct rtattr *tb[TCA_DEF_MAX];
> > +	struct tc_defact *parm;
> > +	struct tcf_defact *p;
> > +	void *defdata;
> > +	u32 datalen = 0;
> > +	int ret = 0;
> > +
> > +	if (rta == NULL || rtattr_parse_nested(tb, TCA_DEF_MAX, rta) < 0)
> > +		return -EINVAL;
> > +
> > +	if (tb[TCA_DEF_PARMS - 1] == NULL)
> > +		return -EINVAL;
> > +	parm = RTA_DATA(tb[TCA_DEF_PARMS - 1]);
> > +	defdata = RTA_DATA(tb[TCA_DEF_DATA - 1]);
> 
> Maybe do a size sanity check here for TCA_DEF_PARMS?
> 

Will do.

> > +
> > +struct tc_defact
> > +{
> > +	tc_gen;
> > +};
> 
> tcf_defact, tc_defact, .. quite easy to get this wrong. Maybe
> it would a good idea to rename tcf_defact to tcf_defact_parm?
> 

sigh. another LinuxWay(tm). Unfortunately this is all over the net/sched
code to imply something thats user specific vs kernel specific. If
you feel strongly about it i will change it - otherwise maybe we can
leave it till some day some brave person will clean up the whole thing?

cheers,
jamal
