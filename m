From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: module loading with CAP_NET_ADMIN
Date: Fri, 25 Feb 2011 18:29:27 +0300
Message-ID: <4D67CAD7.7060408@msgid.tls.msk.ru>
References: <20110224151238.GA16916@albatros> <1298565265.2613.16.camel@bwh-desktop> <20110225123023.GA8776@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Kees Cook <kees.cook@canonical.com>,
	Eugene Teo <eugene@redhat.com>,
	Dan Rosenberg <dan.j.rosenberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110225123023.GA8776@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

25.02.2011 15:30, Vasiliy Kulikov wrote:
> On Thu, Feb 24, 2011 at 16:34 +0000, Ben Hutchings wrote:
>> On Thu, 2011-02-24 at 18:12 +0300, Vasiliy Kulikov wrote:
>>> My proposal is changing request_module("%s", name) to something like
>>> request_module("netdev-%s", name) inside of dev_load() and adding
>>> aliases to related drivers.

It is not the kernel patching which we should worry about, kernel
part is trivial.

What is not trivial is to patch all the systems out there who
autoloads network drivers based on /etc/modprobe.d/network-aliases.conf
(some local file), ie, numerous working setups which already
uses this mechanism since stone age.  And patching these is
not trivial at all, unfortunately.

Somewhat weird setups (one can load the modules explicitly, and
nowadays this all is handled by udev anyway), but this change
will break some working systems.

Maybe the cost (some pain for some users) isn't large enough
but the outcome is good, and I think it _is_ good, but it needs
some wider discussion first, imho.

I can't think of a way to handle this without breaking stuff.

Thanks!

/mjt
