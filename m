From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: add write access to debugfs
 regs file
Date: Wed, 8 Jul 2015 22:53:48 +0200
Message-ID: <20150708205348.GH1357@lunn.ch>
References: <1436387779-23407-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436387779-23407-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 08, 2015 at 04:36:18PM -0400, Vivien Didelot wrote:
> Allow write access to the regs file in the debugfs interface, with the
> following parameters:
> 
>     echo <name> <reg> <value> > regs
> 
> Where "name" is the register name (as shown in the header row), "reg" is
> the register address (as shown in the first column) and "value" is the
> 16-bit value. e.g.:
> 
>     echo GLOBAL 1a 5550 > regs
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 32 +++++++++++++++++++++++++++++++-
>  1 file changed, 31 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 8c130c0..04e6eb6 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1648,6 +1648,35 @@ static int mv88e6xxx_regs_show(struct seq_file *s, void *p)
>  	return 0;
>  }
>  
> +static ssize_t mv88e6xxx_regs_write(struct file *file, const char __user *buf,
> +				    size_t count, loff_t *ppos)
> +{
> +	struct seq_file *s = file->private_data;
> +	struct dsa_switch *ds = s->private;
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	char name[count];

Is this safe? Is count somehow limited? If i was to echo 8K to the
file would i not exceed the kernel stack space?

     Andrew
