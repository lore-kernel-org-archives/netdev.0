From: Jason Lunz <lunz@falooley.org>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond interfaces
Date: Mon, 12 Jan 2004 00:13:46 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnc03pm8.3sp.lunz@orr.homenet>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com> <200401111628.07930.amir.noam@intel.com> <4001A667.2020904@pobox.com> <4001C158.6040103@candelatech.com> <4001C72E.8030108@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jgarzik@pobox.com said:
> The key question is what is the best interface for userland to configure 
> in-kernel information -that is unrelated to a specific interface-. 
> ethtool ioctl space doesn't apply, because that's a per-interface API.

ethtool is just as bad as brctl or any of the others. From (userland)
ethtool.c:

	static int doit(void)
	{
		struct ifreq ifr;
		int fd;

		/* Setup our control structures. */
		memset(&ifr, 0, sizeof(ifr));
		strcpy(ifr.ifr_name, devname);
		/* Open control socket. */
		fd = socket(AF_INET, SOCK_DGRAM, 0);
		if (fd < 0) {
			perror("Cannot get control socket");
			return 70;
		}

		/* now do ioctl() on fd, having nothing to do with
		 * AF_INET nor SOCK_DGRAM */

calling a spade a spade, and all that. I don't see how that's any better
than brctl. The per-interface only comes into it when you copy a dev
name into a struct ifreq, but that doesn't associate the fd with the
interface in any way. You could go ahead and issue another ioctl on the
same fd for a different interface. 

Jason
