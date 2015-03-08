From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH net-next] vlan: allow changing VLAN id and protocol
Date: Sun, 08 Mar 2015 11:25:42 -0700
Message-ID: <54FC9426.7040708@gmail.com>
References: <20150308110624.5ab6f662@urahara>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35051 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbbCHSZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 14:25:45 -0400
Received: by pdbfp1 with SMTP id fp1so38391465pdb.2
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 11:25:44 -0700 (PDT)
In-Reply-To: <20150308110624.5ab6f662@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

On 03/08/2015 11:06 AM, Stephen Hemminger wrote:
> 
> The VLAN netlink interface allows changing the ID and protocol of an existing
> VLAN, but it was being ignored. Move the initialization of the proto and
> id into the change function to fix that.
> 
> Example of the problem:
>   # modprobe dummy
>   # ip li set dev dummy0 up
>   # ip li add link dummy0 name dummy0.10 type vlan id 100
>   # ip li set dummy0.10 type vlan id 111
>   # ip -d li show dev dummy0.10
> 19: dummy0.10@dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT 
>     link/ether be:d3:7c:7f:86:18 brd ff:ff:ff:ff:ff:ff
>     vlan id 100 <REORDER_HDR> 
>             ^^^ should be 111
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Reviewed-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJU/JQlAAoJEOVv75VaS+3OnY8P/2JXfEavZqtBzK2wSRxaJ5o0
PU8FVutYDQ/DFFixEFtIaMY+nVpuViRXmUfowUEbXI5VOeoqwxhC5ek1V4c1TeAl
1gac0oY0ynqFHuAkj2MCkTR32IuOoLEjphekeYbJsLoMY4lF6iCXlQiJ+fboethk
u10p10l4nE16gKCohLvrfW9TjXKF0SiRN70tqOWwwyrhL8YYL4ifE3AQbt3cStvw
wzKrraMueodhtG1SJqVPnr2Iui7LN1hwQFH+J6V0RPYc6hqenQewgP+s4TaWd/a0
9iur1uJXnXvHGihh7HHIuF8ARQhSwlNRMXIq1T87F/qZIpHuUOouMDBZrrgSyBjJ
QAM9gSL5Yd9HX91W1wxl00dvc00GdZFd+x9Zb7ROV42biiA1Yudua3TjzqEbwc61
JM5kR7GUiThqPcWmC+9YjYCbE1ciidepD3LxtjKBQdVIdDUiim0jLzUv1d45L3ne
hsGuB6F64M0iTEHxM8c8NhwYiOpnl6lqaKAHAyGhBKLLlGkAyuktIr8+eXImxTz8
xu7q/DdX/z9/l8rNiqZmM9dI7cOrsW3BgvMi+/bpcbwe8vwIdir/GUpQ0duapG8z
OiNt5Xqda18FsFUyLRe1iq1YbeRLpRt0c+guMMTqLaa1m4i2LwiEEnKF8Ofklk6q
vA4U4evsyN4ROSUjJbAe
=yuzw
-----END PGP SIGNATURE-----
