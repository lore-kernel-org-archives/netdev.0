From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Wed, 1 Oct 2003 05:42:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031001054226.126cea7b.davem@redhat.com>
References: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 01 Oct 2003 07:34:25 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> i am thinking about doing the following to fix the race
> during ATM_ITF_ANY operation.  rtnl is held across 
> registration/unregistration.  this means that you can get
> read-only access to the device list by holding rtnl
> or a read_lock on atm_dev_lock similar to the scheme
> used by netdevice (or so i think).

This looks like it would work.

Although, unless VCC connect can potentially sleep, it might
be better to keep exporting the rwlock and take it as a reader
instead of grabbing the rtnl semaphore.
