From: Olof Johansson <olof@austin.ibm.com>
Subject: Re: [2.4] e1000 leaking pci mappings on rx errors?
Date: Mon, 12 Jan 2004 14:47:41 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <400307ED.3060900@austin.ibm.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDDC5@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cramerj <cramerj@intel.com>, milliner@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDDC5@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
>>We have a machine here (running a RHEL 2.4.21-based kernel), 
>>that started showing leakage of PCI mappings when the driver 
>>was upgraded from 5.1.11 to 5.2.20.
> 
> 
> Olof, please try 5.1.13 and 5.2.16 from sf.net/projects/e1000 to help
> narrow the diff.  I'm not seeing anything obvious in the diff between
> 5.1.11 and 5.2.20 that would explain this.

Scott,

5.1.13 is OK, 5.2.16 is leaking.

Also, I noticed it's leaking quite fast, and even before any RX errors 
are shown. So my previous guess w.r.t. cause and effect might have been 
wrong:

[root@primerib linux-2.4.21-6.EL-olof]# netstat -i
Kernel Interface table
Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP 
TX-OVR Flg
eth1       1500   0    54793      0      0      0    67048      0      0 
      0 BMRU

~6240 PCI mappings had been allocated with the above statistics (eth1 is 
the problematic interface in our case).


-Olof

-- 
Olof Johansson                                        Office: 4F005/905
pSeries Linux Development                             IBM Systems Group
Email: olof@austin.ibm.com                          Phone: 512-838-9858
All opinions are my own and not those of IBM
