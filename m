From: Stefan Rompf <srompf@isg.de>
Subject: Re: Flush Tx skbs after link down
Date: Wed, 15 Jan 2003 10:50:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E252EE9.D8CA8EDC@isg.de>
References: <C6F5CF431189FA4CBAEC9E7DD5441E01087ADF@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "Cramer, Jeb J" <jeb.j.cramer@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> Someone most know the answer to this: What's the proper way to dispose
> of Tx skbs that are owned by the h/w ("in-flight") when link was lost?

I think this can't be achieved without driver support, simply because
pending DMA transfers must be removed before freeing the skbs, and this
is specific. So the driver model needs to be extended to have a reset
method similiar to the qdiscs. If available, this method is called on
link down event by the linkwatch stuff included in recent 2.5 kernels.

Stefan
