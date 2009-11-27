From: Narendra K <Narendra_K@dell.com>
Subject: [PROPOSAL]: Support Alternate Network Device Naming Schemes
Date: Fri, 27 Nov 2009 03:42:58 -0600
Message-ID: <20091127094257.GA24624@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, sandeep_k_shandilya@dell.com,
	jordan_hargrave@dell.com, shyam_iyer@dell.com
To: anaconda-devel-list@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:64067 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbZK0Jmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 04:42:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We have been having discussions in the netdev list about creating multiple names for the network interfaces to bring determinism into the way network interfaces are named in the OSes. In specific, "eth0 in the OS does not always map to the integrated NIC Gb1 as labelled on the chassis".  

http://marc.info/?l=linux-netdev&m=125510301513312&w=2 - (Re: PATCH: Network Device Naming mechanism and policy)
http://marc.info/?l=linux-netdev&m=125619338904322&w=2 - ([PATCH] udev: create empty regular files to represent net)

As a result of those discussions, we propose an installer based solution.

Installers as of now allow the discovered network interfaces to be configured. This solution proposes to provide an option for the users to either retain the default naming convention that the kernel now has, i.e ethN names or rename the network interfaces based on the chassis label, MAC addresses, Driver name and any other naming convention. Here is how the modified network configuration wizard would look during the os installation process - 


---------- Network Configuration ------------------------

Default [ ] |  SMBIOS Names [x]     |  Driver Names []  | MAC Names []
-----------------------------------------------------------------------
 eth0       | Addin_NIC_1           | ice0              |            
-----------------------------------------------------------------------
 eth1       | Embedded_NIC_1        | bce0              |             
-----------------------------------------------------------------------
 eth2       | Embedded_NIC_2        | bce1              |             
-----------------------------------------------------------------------
 eth3       | Embedded_NIC_3        | bce2              |            
-----------------------------------------------------------------------
 eth4       | Embedded_NIC_4        | bce3              |            
-----------------------------------------------------------------------

                                                        ------------
                                                        | Next     |
                                                        ------------

[ ice0 - Intel Controller 0, bce0 - Broadcom Controller 0 ] 

1. In addition to the default ethN names the user can check against the available naming conventions and the wizard would show the names the interfaces will be renamed to.
2. The moment the user hits the Next button all interfaces are renamed as per the Naming convention they have selected.
3. Any further network communication would  be using the new names.
4. Ifconfig would show names like "Embedded_NIC_1" and not eth0 etc.

This way the OS names of network interfaces would have a co-relation to the chassis names. Irrespective of what the OS names the integrated port one, i.e eth0 or eth1, Embedded_NIC_1 will always refer to the integrated port 1, bringing in determinism.

Additional Reference:
http://marc.info/?l=linux-hotplug&m=125692284431543&w=2
http://marc.info/?l=linux-netdev&m=125683519310462&w=2
http://marc.info/?l=linux-netdev&m=125754944814387&w=2
http://marc.info/?l=linux-hotplug&m=125536996902867&w=2

With regards,
Narendra K
