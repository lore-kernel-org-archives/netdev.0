From: Oliver Neukum <oneukum@suse.de>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Fri, 21 Mar 2014 09:33:45 +0100
Message-ID: <1395390825.5171.3.camel@linux-fkkt.site>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	 <CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	 <CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	 <1394529263.16128.6.camel@linux-fkkt.site>
	 <CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	 <CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
	 <1395093343.3961.2.camel@linux-fkkt.site>
	 <CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ@mail.gmail.com>
	 <CAODwPW-E-3HcXCGEmp9JpW6hU-Xt-FHwBtqeSSTDGaRPqO49Sw@mail.gmail.com>
	 <CANEJEGscbVF3gRLNtTAcRSpHGVm1iDDKEeBscXcwj2-YdkiDXA@mail.gmail.com>
	 <CANEJEGtZF30=bqkErvi1CFZLbk=PJ-p_gKf9eBGU7sWwJcrefg@mail.gmail.com>
	 <1395299705.5432.12.camel@linux-fkkt.site>
	 <CANEJEGu3j4a6LOiyD-Qbs5nX4wc4spWQB3ZukmEa1J6VPUg+=g@mail.gmail.com>
	 <CANEJEGues6qVUEpWR5ggejg7dmS1PqzOHvZeWdxGJSnJh6c8Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>,
	Julius Werner <jwerner@chromium.org>
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37119 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbaCUIdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 04:33:46 -0400
In-Reply-To: <CANEJEGues6qVUEpWR5ggejg7dmS1PqzOHvZeWdxGJSnJh6c8Tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-20 at 14:19 -0700, Grant Grundler wrote:
> On Thu, Mar 20, 2014 at 9:35 AM, Grant Grundler <grundler@google.com> wrote:
> > On Thu, Mar 20, 2014 at 12:15 AM, Oliver Neukum <oneukum@suse.de> wrote:
> > ...
> >> I have an idea. Could you test this patch?
> > ...
> >> -       if (dev->wait) {
> > ..
> >> +       if (waitqueue_active(&dev->wait)) {
> >
> > Yes - building new image now (and transfer to USB and boot from USB).
> > Should know in an hour or so (doing other things in parallel).
> 
> Sorry...took a bit longer since my previous test method (bash
> /tmp/reload_asix) was abusing a security exploit that is now
> fixed...so had to move my script into a RO executable file system:
> 
> for i in `seq 10000`; do echo -n "RELOAD $i  " ; ssh $T
> "/bin/reload_asix eth0 1000_full" ; J=$? ; if [ $J -eq 255 ] ; then
> echo; " SSH timeout" ; break ; fi ; ssh $T "cat
> /var/log/reload-asix.out" ; if [ $J -ne 0 ] ; then echo "  ERROR $J" ;
> fi ; sleep 3 ; done | tee ~/reload-AX88178-leon-192.168.1.100-06.out
> 
> This is running now and things look happy so far. :) This will take
> more than 30h to complete.

Very well. Thorough testing is good. I'll wait for the result. Could
you notify me of the final outcome?

And, Julius, I owe you an apology. The check is necessary.

	Regards
		Oliver
