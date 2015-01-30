From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH v2 11/11] hso: fix rfkill name conflicts
Date: Fri, 30 Jan 2015 10:59:02 -0600
Message-ID: <1422637142.30854.7.camel@dcbw.local>
References: <1422620523-15021-4-git-send-email-olivier@sobrie.be>
	 <1422620523-15021-5-git-send-email-olivier@sobrie.be>
	 <1422620523-15021-6-git-send-email-olivier@sobrie.be>
	 <1422620523-15021-7-git-send-email-olivier@sobrie.be>
	 <1422620523-15021-8-git-send-email-olivier@sobrie.be>
	 <1422620523-15021-9-git-send-email-olivier@sobrie.be>
	 <1422620523-15021-10-git-send-email-olivier@sobrie.be>
	 <1422620523-15021-11-git-send-email-olivier@sobrie.be>
	 <1422620523-15021-12-git-send-email-olivier@sobrie.be>
	 <1422632879.30854.0.camel@dcbw.local>
	 <20150130161555.GA22140@thinkoso.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Dumon <j.dumon@option.com>, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150130161555.GA22140@thinkoso.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-01-30 at 17:15 +0100, Olivier Sobrie wrote:
> Hello Dan,
> 
> On Fri, Jan 30, 2015 at 09:47:59AM -0600, Dan Williams wrote:
> > On Fri, 2015-01-30 at 13:22 +0100, Olivier Sobrie wrote:
> > > By using only the usb interface number for the rfkill name, we might
> > > have a name conflicts in case two similar hso devices are connected.
> > > 
> > > In this patch, the name of the hso rfkill interface embed the value
> > > of a counter that is incremented each time a new rfkill interface is
> > > added.
> > > 
> > > Suggested-by: Dan Williams <dcbw@redhat.com>
> > > Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
> > > ---
> > >  drivers/net/usb/hso.c | 5 +++--
> > >  1 file changed, 3 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> > > index c14fc80..d31a165 100644
> > > --- a/drivers/net/usb/hso.c
> > > +++ b/drivers/net/usb/hso.c
> > > @@ -153,7 +153,7 @@ struct hso_net {
> > >  	struct hso_device *parent;
> > >  	struct net_device *net;
> > >  	struct rfkill *rfkill;
> > > -	char name[8];
> > > +	char name[24];
> > >  
> > >  	struct usb_endpoint_descriptor *in_endp;
> > >  	struct usb_endpoint_descriptor *out_endp;
> > > @@ -2469,9 +2469,10 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
> > >  {
> > >  	struct hso_net *hso_net = dev2net(hso_dev);
> > >  	struct device *dev = &hso_net->net->dev;
> > > +	static u32 rfkill_counter;
> > 
> > It'll probably be initialized to 0, but still, it would feel safer with
> > an explicit "rfkill_counter = 0"...
> > 
> 
> If I set explicitly rfkill_counter = 0, checkpatch triggers an error:
> 
>   ERROR: do not initialise statics to 0 or NULL
>   #36: FILE: drivers/net/usb/hso.c:2472:
>   +	static u32 rfkill_counter = 0;

Well OK then, life has changed since I last submitted a patch with a
static variable :)  If checkpatch complains, then it is almost always
correct, and you can ignore me.

Dan
