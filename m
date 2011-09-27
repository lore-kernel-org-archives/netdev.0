From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: intel 82599 multi-port performance
Date: Tue, 27 Sep 2011 16:57:33 -0600
Message-ID: <4E8254DD.6020908@genband.com>
References: <4E805359.2080600@gmail.com> <4E808A41.8040902@genband.com> <4E809D59.10103@gmail.com> <4E80A2AB.2040206@intel.com> <4E811C8E.8020508@gmail.com> <4E820486.4090204@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "J.Hwan Kim" <frog1120@gmail.com>, netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og113.obsmtp.com ([64.18.2.179]:42579 "EHLO
	exprod7og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039Ab1I0W7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 18:59:19 -0400
In-Reply-To: <4E820486.4090204@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2011 11:14 AM, Alexander Duyck wrote:

> This more or less confirms what I was thinking. You are likely hitting
> the PCIe limits of the adapters. The overhead for 64 byte packets is too
> great and as a result you are exceeding the PCIe bandwidth available to
> the adapter. In order to achieve line rate on both ports you would
> likely need to increase your packet size to something along the lines of
> 256 bytes so that the additional PCIe overhead only contributes 50% or
> less to the total PCIe traffic across the bus. Then the 2.5Gb/s of
> network traffic should consume less than 4.0GT/s of PCIe traffic.


For some further information, according to the information here:

http://shader.kaist.edu/packetshader/io_engine/benchmark/i3.html

a dual-port 82599 controller with an i3 CPU can in fact handle sending 
*or* receiving (and then dropping) full line rate on both ports for 
minimum-sized packets.  It can't do both though.  The CPU used in tose 
tests isn't the greatest however, so it's tough to say where the 
bottleneck is.


Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
