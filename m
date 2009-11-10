From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: sunrpc port allocation and IANA reserved list
Date: Tue, 10 Nov 2009 12:48:50 -0600
Message-ID: <4AF9B592.6030309@nortel.com>
References: <4AF9A63B.6010101@nortel.com> <1257875623.2834.19.camel@achroite.uk.solarflarecom.com> <4AF9B2CF.6050305@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>, twaugh@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757631AbZKJSuM@vger.kernel.org>
In-Reply-To: <4AF9B2CF.6050305@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/10/2009 12:37 PM, Chris Friesen wrote:
> On 11/10/2009 11:53 AM, Ben Hutchings wrote:
>> On Tue, 2009-11-10 at 11:43 -0600, Chris Friesen wrote:
> 
>>> Given that a userspace application can be stopped and restarted at any
>>> time, and a sunrpc registration can happen at any time, what is the
>>> expected mechanism to prevent the kernel from allocating a port for use
>>> by sunrpc that reserved or well-known?
>>>
>>> Apparently Redhat and Debian have distro-specific ways of dealing with
>>> this, but is there a standard solution?  Should there be?
>>>
>>> The current setup seems suboptimal.
>>
>> I believe both RH and Debian are using the same implementation:
>> <http://cyberelk.net/tim/software/portreserve/>.
> 
> That helps with the startup case, but still leaves a possible hole if an
> app using a fixed port number is restarted at runtime.  During the
> window where nobody is bound to the port, the kernel could randomly
> assign it to someone else.

After some reflection it seems to me that the only way to close this
race condition is to store the list of reserved ports in the kernel and
simply avoid handing out a reserved address unless it is specifically
requested.

Maybe we could keep the config files of the existing portreserve
package, but rather than maintaining the reservation list itself the
portreserve app would simply feed the reservations into the kernel (via
/proc or netlink or something) at startup.

This would also avoid the need to modify the startup scripts of
applications wanting to use a fixed port.  The config file containing
the port number would still be necessary, however.

Chris
