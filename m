From: "David S. Miller" <davem@redhat.com>
Subject: Re: e1000 close (NAPI)
Date: Wed, 8 Oct 2003 05:07:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008050720.7d65bd88.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229702@orsmsx402.jf.intel.com>
	<16259.54738.75122.134408@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: scott.feldman@intel.com, Robert.Olsson@data.slu.se, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16259.54738.75122.134408@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Oct 2003 11:16:02 +0200
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> Feldman, Scott writes:
>  > > -	if(work_done < work_to_do) {
>  > > +	if(work_done < work_to_do || !netif_running(netdev)) {
>  > >  		netif_rx_complete(netdev);
>  > >  		e1000_irq_enable(adapter);
>  > >  	}
>  > 
>  > Is e1000 unique in this regard, or do the other NAPI-enabled drivers
>  > have the same issue?
> 
>  Other drivers may have the same issue. This was spotted while stress-testing 
>  tulip. Patch was sent here some days ago. It's only seen if trying to close 
>  device under extreme loads. See the syncing code in dev_close()
> 
>  You may try the e100 as well. We update the docs when see that this is OK.

We should just fix all the NAPI drivers in this regard at one
time.  Undoubtedly tg3 needs this change too.
