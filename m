From: Andi Kleen <ak@suse.de>
Subject: Re: some bluetooth fixes
Date: Wed, 11 Feb 2004 19:55:01 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040215002513.7c6fc532.ak__13208.5964819$1076529301@suse.de>
References: <20040206050042.20a2b3b0.ak@suse.de>
	<1076079512.2806.40.camel@pegasus>
	<20040207032428.56ffbebc.ak@suse.de>
	<1076152411.14418.73.camel@pegasus>
	<20040207125723.391a1fcd.ak@suse.de>
	<1076173068.2670.4.camel@pegasus>
	<20040207172436.GB449@wotan.suse.de>
	<1076525743.2792.1.camel@pegasus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bluez-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        viro@zenII.linux.org.uk
Return-path: <netdev-bounce@oss.sgi.com>
Date: Sun, 15 Feb 2004 00:25:13 +0100
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1076525743.2792.1.camel@pegasus>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Feb 2004 19:55:43 +0100
Marcel Holtmann <marcel@holtmann.org> wrote:

> Hi Andi,
> 
> > Doing size checks after the multiply is too late - they could
> > have already overflowed. You have to check the raw value from the user.
> 
> new patch is attached.


+	if (req.conn_num * sizeof(*ci) > PAGE_SIZE * 2)
+		return -EINVAL;

This can still overflow. It should be 

	if (req.conn_num > (PAGE_SIZE * 2)/sizeof(*ci))
		return -EINVAL

-Andi
