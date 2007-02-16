From: John Rose <johnrose@austin.ibm.com>
Subject: Re: [PATCH 2.6.21-rc1] ehea: dynamic add / remove port
Date: Fri, 16 Feb 2007 09:51:29 -0600
Message-ID: <1171641089.9442.8.camel@sinatra.austin.ibm.com>
References: <200702141536.28665.ossthema@de.ibm.com>
	 <1171491906.30473.3.camel@sinatra.austin.ibm.com>
	 <200702161606.52789.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <RAISCH@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, stefan.roscher@de.ibm.com,
	netdev <netdev@vger.kernel.org>,
	Nathan Fontenot <nfont@austin.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:33930 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945953AbXBPPy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 10:54:26 -0500
In-Reply-To: <200702161606.52789.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi-

Sounds good.  A couple of questions/comments:

> I think it is not necessary to have a special entry/kobject for each logical
> port. I suggest we use SET_NETDEV_DEV to create links to all ethernet devices
> that represent each a logical port. This should be in sync with all other 
> ethernet drivers. Port attributes like the "logical port id" that might be 
> need by the userspace application can be added to the net:ethX entry
> (link created with SET_NETDEV_DEV) as additional attributes. 

As we develop the userspace tool, we are finding a need to know the
following for each logical port:

1) the linux interface/device (a symlink would do this)
2) the logical port number - were you suggesting communicating this
through the name of the symlink, or in the directory of the symlink
target?
3) the open firmware path for the logical port.  This is typically
communicated through a sysfs attribute file "devspec", but we can't do
this without a new kobject for the port.

> > 
> > Second, the probe and remove functions do not communicate whether an add
> > or remove was successful.  Combine this with the lack of port
> > information in the adapter sysfs directory, and the userspace tool has
> > no way of verifying a dynamic add/remove.
> 
> True. I suggest we return error codes (-EIO / -EINVAL) in case the adding
> or removing of ports fails. This is possible as we know instantly if the
> operation failed or not. It is a synchronus operation.

Sounds good.

Thanks!
John

