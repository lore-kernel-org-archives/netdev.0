From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Convert multiple netdev_info messages to netdev_dbg
Date: Thu, 15 Jun 2017 19:03:46 -0700
Message-ID: <1497578626.10546.1.camel@perches.com>
References: <1497550452-3067-1-git-send-email-michael.j.dilmore@gmail.com>
         <1497563676.14396.19.camel@perches.com> <21519.1497577761@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Michael J Dilmore <michael.j.dilmore@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21519.1497577761@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-06-15 at 18:49 -0700, Jay Vosburgh wrote:
> Joe Perches <joe@perches.com> wrote:
> 
> > On Thu, 2017-06-15 at 19:14 +0100, Michael J Dilmore wrote:
> > > Multiple netdev_info messages clutter kernel output. Also add netdev_dbg for packets per slave.
> > 
> > []
> > > diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> > 
> > []
> > > @@ -9,6 +9,8 @@
> > >   * (at your option) any later version.
> > >   */
> > >   
> > > +#define DEBUG 1
> > 
> > Is defining DEBUG really worthwhile.

Question was really if it's worthwhile to have
that logging always emitted at debug level or if
it's only useful when debugging.

I generally think smaller object code is better
and if it's not necessary, debugging output is
better not enabled/compiled into the kernel.

> 	I don't believe so, since if CONFIG_DYNAMIC_DEBUG is not
> enabled, having #define DEBUG will enable all of the netdev_dbg messages
> unconditionally, which is the opposite of the stated purpose of the
> patch.  If DYNAMIC_DEBUG is enabled, having DEBUG doesn't do anything
> that I can see.

Having #define DEBUG means that by default the
dynamic_debug output logging is enabled in the
control file, otherwise it's not emitted unless
it's specifically enabled by a user.

include/linux/dynamic_debug.h:#ifdef DEBUG
include/linux/dynamic_debug.h-#define DEFINE_DYNAMIC_DEBUG_METADATA(name, fmt) \
include/linux/dynamic_debug.h-  DEFINE_DYNAMIC_DEBUG_METADATA_KEY(name, fmt, .key.dd_key_true, \
include/linux/dynamic_debug.h-                                    (STATIC_KEY_TRUE_INIT))
