From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] support for large number of network devices.
Date: Tue, 13 Jan 2004 23:54:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4004F5D0.7040106@candelatech.com>
References: <20040113154610.38f5934c.shemminger@osdl.org>	<40048BFD.4010303@candelatech.com>	<20040113163828.64ec4743.shemminger@osdl.org>	<4004A194.3030602@candelatech.com> <20040113231825.700e534f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040113231825.700e534f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> Therefore, I think it's wise to just do this right from the start and use a hash.
> Stephen can you test up and submit the netdev name hash patch you have?
> 

In case it proves useful, here's the hash I used before.  It makes some
assumptions based on the fact that the last two characters of a device name
are often numbers, especially when you have lots of devices.  Someone
did a mapping of this and found it worked well for vlans, at least.


int fdl_calc_name_idx(const char* dev_name) {
  int tmp = 0;
  int i;

  for (i = 0; dev_name[i]; i++) {
    tmp += (int)(dev_name[i]);
  }
  if (i > 3) {
    tmp += (dev_name[i-2] * 10); /* might add a little spread to the hash */
    tmp += (dev_name[i-3] * 100); /* might add a little spread to the hash */
  }
  return (tmp % FDL_HASH_LEN);
}


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
