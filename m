From: Thomas Graf <tgraf@suug.ch>
Subject: Re: cls_u32 compile failure in current 2.6.12-rc1+BK tree
Date: Mon, 28 Mar 2005 17:55:23 +0200
Message-ID: <20050328155523.GD3086@postel.suug.ch>
References: <Pine.SOC.4.61.0503272249040.5086@math.ut.ee> <1111972035.1091.946.camel@jzny.localdomain> <Pine.SOC.4.61.0503281017060.21333@math.ut.ee> <1112012657.1089.1013.camel@jzny.localdomain> <20050328123801.GY3086@postel.suug.ch> <1112014261.1089.1018.camel@jzny.localdomain> <20050328125802.GZ3086@postel.suug.ch> <1112015725.1089.1045.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Meelis Roos <mroos@linux.ee>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112015725.1089.1045.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1112015725.1089.1045.camel@jzny.localdomain> 2005-03-28 08:15
> On Mon, 2005-03-28 at 07:58, Thomas Graf wrote:
> 
> > Not sure what you mean, I don't want any ifdefs or actions bits
> > in the classifiers itself anymore. Everytime we dump the actions
> > we must be able to also dump the statistics so I think we can
> > safely move tcf_exts_dump_stats into tcf_exts_dump and hide all
> > dumping in that single API.
> > 
> 
> But you cant completely do this for u32 tcf_exts_dump_stats.
> in the case of ACTION compiled in but someone using old API.
> The code that Meelis just mention that compiler complained about. 
> There was no problem with u32 and tcf_exts_dump - with that you can hide
> all #ifedfs. 

I think we can avoid your fixes. The initial reason for having
dump_stats was that the statistics were put into a TLV outside
of TCA_OPTIONS (which was wrong). Now that both, the new and old
compatibility stats are inside of TCA_OPTIONS it is no problem
do dump everything in tcf_exts_dump and do the ifdef thing there
instead of putting it into every classifier.
