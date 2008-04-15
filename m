From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 09:11:58 -0700
Message-ID: <20080415161158.GE9704@kroah.com>
References: <20080414213238.GB28833@kroah.com> <48042F7F.8030608@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org
To: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48042F7F.8030608-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 15, 2008 at 06:30:55AM +0200, Oliver Hartkopp wrote:
> Just some obvious things to reduce the source code hopping for the
> review and to reduce the source code size.
> 
> Regards,
> Oliver
> 
> > +
> > +#define DRIVER_VERSION			"1.2"
> > +#define MOD_AUTHOR			"Option Wireless"
> > +#define MOD_DESCRIPTION			"USB High Speed Option driver"
> > +#define MOD_LICENSE			"GPL"
> > +
> >   
> 
> Please move the MODULE_OWNER(), MODULE_LICENSE(), etc. macros from the
> end of this file directly to this point.

Does that really matter?

> > +/*****************************************************************************/
> > +/* Prototypes                                                                */
> > +/*****************************************************************************/
> >   
> 
> This is a real forward declaration hell. Please try to reorder the
> functions in the code to make this as obsolte as possible.

I've already stripped down a lot of them, will work on the remaining
ones, I wanted to get the code out for review first.

> > +/*****************************************************************************/
> > +/* Helping functions                                                         */
> > +/*****************************************************************************/
> > +
> > +/* convert a character representing a hex value to a number */
> > +static unsigned char hex2dec(unsigned char digit)
> > +{
> > +
> > +	if ((digit >= '0') && (digit <= '9'))
> > +		return (digit - '0');
> > +	/* Map all characters to 0-15 */
> > +	if ((digit >= 'a') && (digit <= 'z'))
> > +		return (digit - 'a' + 10) % 16;
> > +	if ((digit >= 'A') && (digit <= 'Z'))
> > +		return (digit - 'A' + 10) % 16;
> > +	return 16;
> > +}
> > +
> >   
> 
> Shouldn't this already be somewhere else in the kernel?

Do you know where?

> > +
> > +/* module parameters */
> > +static int debug;
> > +static int procfs = 1;
> > +static int tty_major;
> > +static int disable_net;
> > +static int enable_autopm;
> > +
> >   
> 
> please move the module_param() stuff and MODULE_PARM_DESC() from the end
> of the file right to this place.

Does it really matter?

> > +static int hso_proc_port_info(char *buf, char **start, off_t offset, int count,
> > +			      int *eof, void *data)
> > +{
> > +	int len = 0;
> > +	struct hso_device *hso_dev = (struct hso_device *)data;
> > +	char *port_name = NULL;
> > +
> > +	D1("count: %d", count);
> >   
> 
> This debug macro looks like it is from the very beginning of the
> implementation. Remove it.

Why?

> > +
> > +static void hso_serial_throttle(struct tty_struct *tty)
> > +{
> > +	D1(" ");
> > +}
> > +
> > +static void hso_serial_unthrottle(struct tty_struct *tty)
> > +{
> > +	D1(" ");
> > +}
> > +
> > +static void hso_serial_break(struct tty_struct *tty, int break_state)
> > +{
> > +	D1(" ");
> > +}
> > +
> > +static int hso_serial_read_proc(char *page, char **start, off_t off, int count,
> > +				int *eof, void *data)
> > +{
> > +	return 0;
> > +}
> > +
> >   
> 
> ???

Already been pointed out that they can be removed.

> > +static void hso_serial_hangup(struct tty_struct *tty)
> > +{
> > +	D1("hang up");
> > +}
> > +
> >
> >   
> 
> Should all these functions be removed (and therefor not set in
> hso_serial_ops) ??

Yes.

thanks for the review.

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
